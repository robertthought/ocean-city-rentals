class PagesController < ApplicationController
  def about
  end

  def contact
    @contact_submitted = false
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
