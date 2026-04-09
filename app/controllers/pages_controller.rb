class PagesController < ApplicationController
  def about
  end

  def pricing
  end

  def privacy_policy
  end

  def terms_of_service
  end

  def testimonials
  end

  def contact
    @contact_submitted = false
  end

  def list_property
    @submission = PropertySubmission.new
  end

  def submit_property
    # Verify reCAPTCHA
    recaptcha_result = RecaptchaVerifier.verify(params[:recaptcha_token], request.remote_ip)
    unless recaptcha_result[:success]
      Rails.logger.warn "[PropertySubmission] reCAPTCHA failed for #{request.remote_ip}: #{recaptcha_result}"
      redirect_to list_property_path, alert: "Verification failed. Please try again."
      return
    end

    @submission = PropertySubmission.new(
      owner_name: params[:owner_name],
      email: params[:email],
      phone: params[:phone],
      property_address: params[:property_address],
      city: params[:city],
      state: params[:state],
      zip: params[:zip],
      bedrooms: params[:bedrooms].presence,
      bathrooms: params[:bathrooms].presence,
      message: params[:message],
      recaptcha_score: recaptcha_result[:score]
    )

    if @submission.save
      PropertySubmissionMailer.new_submission(@submission).deliver_later

      redirect_to list_property_path, notice: "Thank you for your submission! We'll review your property and get back to you within 48 hours."
    else
      flash.now[:alert] = "Please fill in all required fields."
      render :list_property
    end
  end

  def rental_request
    @rental_request = RentalRequest.new
  end

  def submit_rental_request
    recaptcha_result = RecaptchaVerifier.verify(params[:recaptcha_token], request.remote_ip)
    unless recaptcha_result[:success]
      Rails.logger.warn "[RentalRequest] reCAPTCHA failed for #{request.remote_ip}: #{recaptcha_result}"
      redirect_to rental_request_path, alert: "Verification failed. Please try again."
      return
    end

    @rental_request = RentalRequest.new(
      name: params[:name],
      email: params[:email],
      phone: params[:phone],
      bedrooms: params[:bedrooms].presence,
      bathrooms: params[:bathrooms].presence,
      sleeps: params[:sleeps].presence,
      check_in_date: params[:check_in_date].presence,
      check_out_date: params[:check_out_date].presence,
      flexible_dates: params[:flexible_dates] == "1",
      location_preferences: params[:location_preferences],
      amenities: params[:amenities],
      budget_min: params[:budget_min].presence,
      budget_max: params[:budget_max].presence,
      additional_comments: params[:additional_comments],
      recaptcha_score: recaptcha_result[:score]
    )

    if @rental_request.save
      redirect_to rental_request_path, notice: "Thank you! Our concierge team will find the perfect rental for you and contact you within 24 hours."
    else
      flash.now[:alert] = "Please fill in all required fields."
      render :rental_request
    end
  end

  def submit_contact
    # Rate limiting by IP: max 5 per hour
    ip_key = "contact_rate:ip:#{request.remote_ip}"
    ip_count = Rails.cache.read(ip_key).to_i
    if ip_count >= 5
      Rails.logger.warn "[Contact] Rate limit hit for IP #{request.remote_ip}"
      redirect_to contact_path, alert: "Too many submissions. Please try again later."
      return
    end

    # Rate limiting by email: max 3 per hour
    email_key = "contact_rate:email:#{params[:email].to_s.downcase.strip}"
    email_count = Rails.cache.read(email_key).to_i
    if email_count >= 3
      Rails.logger.warn "[Contact] Rate limit hit for email #{params[:email]}"
      redirect_to contact_path, alert: "Too many submissions. Please try again later."
      return
    end

    # Verify reCAPTCHA
    recaptcha_result = RecaptchaVerifier.verify(params[:recaptcha_token], request.remote_ip)
    unless recaptcha_result[:success]
      Rails.logger.warn "[Contact] reCAPTCHA failed for #{request.remote_ip}: #{recaptcha_result}"
      redirect_to contact_path, alert: "Verification failed. Please try again."
      return
    end

    spam_reasons = SpamDetector.detect(
      name: params[:name],
      email: params[:email],
      phone: params[:phone],
      message: params[:message],
      recaptcha_score: recaptcha_result[:score],
      honeypot: params[:website]
    )
    is_spam = spam_reasons.any?

    @submission = ContactSubmission.new(
      name: params[:name],
      email: params[:email],
      phone: params[:phone],
      message: params[:message],
      inquiry_type: params[:inquiry_type],
      recaptcha_score: recaptcha_result[:score],
      spam: is_spam,
      spam_reason: spam_reasons.join(", ").presence
    )

    if @submission.save
      Rails.cache.write(ip_key, ip_count + 1, expires_in: 1.hour)
      Rails.cache.write(email_key, email_count + 1, expires_in: 1.hour)

      unless is_spam
        ContactMailer.new_contact(
          name: @submission.name,
          email: @submission.email,
          phone: @submission.phone,
          message: @submission.message,
          inquiry_type: @submission.inquiry_type
        ).deliver_later
      else
        Rails.logger.warn "[Contact] Spam detected from #{request.remote_ip}: #{spam_reasons.join(', ')}"
      end

      redirect_to contact_path, notice: "Thank you for your message! We'll get back to you within 24 hours."
    else
      flash.now[:alert] = "Please fill in all required fields."
      @contact_submitted = false
      render :contact
    end
  end
end
