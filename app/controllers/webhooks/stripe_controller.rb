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
