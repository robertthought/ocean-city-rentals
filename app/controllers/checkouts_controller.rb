class CheckoutsController < ApplicationController
  # Each plan covers 1 property. Multiple properties = multiply the price.
  PLANS = {
    "starter" => {
      name: "Starter",
      price_cents: 24900,
      photos_limit: 15
    },
    "professional" => {
      name: "Professional",
      price_cents: 49900,
      photos_limit: 40
    },
    "premium" => {
      name: "Premium",
      price_cents: 89900,
      photos_limit: nil # unlimited
    }
  }.freeze

  def new
    @plan = params[:plan]

    unless PLANS.key?(@plan)
      redirect_to pricing_path, alert: "Invalid plan selected."
      return
    end

    @plan_details = PLANS[@plan]
  end

  def create
    plan = params[:plan]

    unless PLANS.key?(plan)
      redirect_to pricing_path, alert: "Invalid plan selected."
      return
    end

    plan_details = PLANS[plan]

    # Create Stripe Checkout Session
    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      success_url: checkout_success_url(plan: plan) + "&session_id={CHECKOUT_SESSION_ID}",
      cancel_url: pricing_url,
      customer_email: params[:email],
      metadata: {
        plan: plan,
        first_name: params[:first_name],
        last_name: params[:last_name]
      },
      line_items: [
        {
          price_data: {
            currency: "usd",
            unit_amount: plan_details[:price_cents],
            recurring: { interval: "year" },
            product_data: {
              name: "OCNJ Weekly Rentals - #{plan_details[:name]} Plan (1 Property)",
              description: "Annual subscription for 1 property listing on OCNJ Weekly Rentals"
            }
          },
          quantity: 1
        }
      ]
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    @plan = params[:plan]
    session_id = params[:session_id]

    if session_id.present?
      begin
        @session = Stripe::Checkout::Session.retrieve(session_id)

        # Find or create user
        user = User.find_by(email: @session.customer_email&.downcase)

        if user.nil? && @session.metadata&.first_name.present?
          # Create new user with temporary password (they'll need to set it)
          temp_password = SecureRandom.hex(16)
          user = User.create!(
            email: @session.customer_email,
            first_name: @session.metadata.first_name,
            last_name: @session.metadata.last_name,
            password: temp_password,
            password_confirmation: temp_password,
            stripe_customer_id: @session.customer,
            subscription_plan: @plan,
            subscription_status: "active",
            stripe_subscription_id: @session.subscription
          )

          # Generate password reset token so they can set their password
          user.generate_reset_token!
          @new_user = true
          @reset_token = user.reset_password_token
        elsif user
          # Update existing user's subscription
          user.update!(
            stripe_customer_id: @session.customer,
            subscription_plan: @plan,
            subscription_status: "active",
            stripe_subscription_id: @session.subscription
          )
          @new_user = false
        end

        @user = user
      rescue Stripe::StripeError => e
        Rails.logger.error "[Checkout] Stripe error: #{e.message}"
        @error = "There was an issue processing your payment. Please contact support."
      end
    end
  end
end
