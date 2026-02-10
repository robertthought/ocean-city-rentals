module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError
        render json: { error: "Invalid payload" }, status: :bad_request
        return
      rescue Stripe::SignatureVerificationError
        render json: { error: "Invalid signature" }, status: :bad_request
        return
      end

      # Handle the event
      case event.type
      when "checkout.session.completed"
        handle_checkout_completed(event.data.object)
      when "customer.subscription.created"
        handle_subscription_created(event.data.object)
      when "customer.subscription.updated"
        handle_subscription_updated(event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(event.data.object)
      when "invoice.payment_succeeded"
        handle_payment_succeeded(event.data.object)
      when "invoice.payment_failed"
        handle_payment_failed(event.data.object)
      else
        Rails.logger.info "[Stripe Webhook] Unhandled event type: #{event.type}"
      end

      render json: { received: true }
    end

    private

    # Payment Link price IDs - update these if you recreate the Payment Links
    PAYMENT_LINK_PRICES = {
      # Map Stripe Price IDs to plan names
      # You can find these in Stripe Dashboard > Products > [Product] > Pricing
      # Or check the checkout.session.completed webhook payload for the price ID
    }.freeze

    def handle_checkout_completed(session)
      customer_email = session.customer_email || session.customer_details&.email
      return unless customer_email.present?

      Rails.logger.info "[Stripe] Checkout completed for #{customer_email}"

      # Determine plan from metadata (set on Payment Link) or line items
      plan = determine_plan_from_session(session)

      # Find or create user
      user = User.find_by(email: customer_email.downcase)

      if user
        # Update existing user
        user.update!(
          stripe_customer_id: session.customer,
          subscription_plan: plan,
          subscription_status: "active",
          stripe_subscription_id: session.subscription
        )
        Rails.logger.info "[Stripe] Updated user #{user.id} to #{plan} plan"
      else
        # Create new user with temporary password
        temp_password = SecureRandom.hex(16)
        user = User.create!(
          email: customer_email.downcase,
          first_name: session.customer_details&.name&.split&.first || "Property",
          last_name: session.customer_details&.name&.split&.last || "Owner",
          password: temp_password,
          password_confirmation: temp_password,
          stripe_customer_id: session.customer,
          subscription_plan: plan,
          subscription_status: "active",
          stripe_subscription_id: session.subscription
        )

        # Generate password reset token so they can set their password
        user.generate_reset_token!

        # Send welcome email with password setup link
        OwnerMailer.welcome_after_payment(user).deliver_later if defined?(OwnerMailer)

        Rails.logger.info "[Stripe] Created new user #{user.id} with #{plan} plan"
      end
    end

    def determine_plan_from_session(session)
      # Check metadata first (if you set plan name on Payment Link)
      return session.metadata&.plan if session.metadata&.plan.present?

      # Try to determine from amount
      amount = session.amount_total
      case amount
      when 24900 then "starter"
      when 49900 then "professional"
      when 89900 then "premium"
      else
        Rails.logger.warn "[Stripe] Unknown amount #{amount}, defaulting to starter"
        "starter"
      end
    end

    def handle_subscription_created(subscription)
      user = User.find_by(stripe_customer_id: subscription.customer)
      return unless user

      Rails.logger.info "[Stripe] Subscription created for user #{user.id}"
    end

    def handle_subscription_updated(subscription)
      user = User.find_by(stripe_customer_id: subscription.customer)
      return unless user

      status = subscription.status == "active" ? "active" : subscription.status

      user.update!(
        subscription_status: status,
        stripe_subscription_id: subscription.id,
        subscription_expires_at: subscription.current_period_end ? Time.at(subscription.current_period_end) : nil
      )

      Rails.logger.info "[Stripe] Subscription updated for user #{user.id}: #{status}"
    end

    def handle_subscription_deleted(subscription)
      user = User.find_by(stripe_customer_id: subscription.customer)
      return unless user

      user.update!(
        subscription_plan: "free",
        subscription_status: "canceled",
        stripe_subscription_id: nil
      )

      Rails.logger.info "[Stripe] Subscription canceled for user #{user.id}"
    end

    def handle_payment_succeeded(invoice)
      user = User.find_by(stripe_customer_id: invoice.customer)
      return unless user

      Rails.logger.info "[Stripe] Payment succeeded for user #{user.id}"
    end

    def handle_payment_failed(invoice)
      user = User.find_by(stripe_customer_id: invoice.customer)
      return unless user

      user.update!(subscription_status: "past_due")
      Rails.logger.info "[Stripe] Payment failed for user #{user.id}"

      # TODO: Send email notification about failed payment
    end
  end
end
