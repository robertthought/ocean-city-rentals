class PagesController < ApplicationController
  def about
  end

  def pricing
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

  def submit_contact
    # Verify reCAPTCHA
    recaptcha_result = RecaptchaVerifier.verify(params[:recaptcha_token], request.remote_ip)
    unless recaptcha_result[:success]
      Rails.logger.warn "[Contact] reCAPTCHA failed for #{request.remote_ip}: #{recaptcha_result}"
      redirect_to contact_path, alert: "Verification failed. Please try again."
      return
    end

    @submission = ContactSubmission.new(
      name: params[:name],
      email: params[:email],
      phone: params[:phone],
      message: params[:message],
      inquiry_type: params[:inquiry_type],
      recaptcha_score: recaptcha_result[:score]
    )

    if @submission.save
      ContactMailer.new_contact(
        name: @submission.name,
        email: @submission.email,
        phone: @submission.phone,
        message: @submission.message,
        inquiry_type: @submission.inquiry_type
      ).deliver_later

      redirect_to contact_path, notice: "Thank you for your message! We'll get back to you within 24 hours."
    else
      flash.now[:alert] = "Please fill in all required fields."
      @contact_submitted = false
      render :contact
    end
  end
end
