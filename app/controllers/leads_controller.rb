class LeadsController < ApplicationController
  def create
    Rails.logger.info "[Lead] Form submitted from #{request.remote_ip}"
    Rails.logger.info "[Lead] Params: #{params.except(:authenticity_token).to_unsafe_h}"

    @property = Property.friendly.find(params[:property_id])
    Rails.logger.info "[Lead] Property found: #{@property.address}"

    # Verify reCAPTCHA
    recaptcha_result = RecaptchaVerifier.verify(params[:recaptcha_token], request.remote_ip)
    Rails.logger.info "[Lead] reCAPTCHA result: #{recaptcha_result}"

    unless recaptcha_result[:success]
      Rails.logger.warn "[Lead] reCAPTCHA failed for #{request.remote_ip}: #{recaptcha_result}"
      redirect_to property_path(@property), alert: "Verification failed. Please try again."
      return
    end

    lead_data = lead_params
    spam_reasons = SpamDetector.detect(
      name: lead_data[:name],
      email: lead_data[:email],
      phone: lead_data[:phone],
      message: lead_data[:message],
      recaptcha_score: recaptcha_result[:score],
      honeypot: params[:website]
    )

    @lead = @property.leads.new(lead_data)
    @lead.ip_address = request.remote_ip
    @lead.user_agent = request.user_agent
    @lead.source = params[:source] || 'direct'
    @lead.recaptcha_score = recaptcha_result[:score]
    @lead.spam = spam_reasons.any?
    @lead.spam_reason = spam_reasons.join(", ").presence

    if @lead.save
      if @lead.spam?
        Rails.logger.warn "[Lead] Spam detected from #{request.remote_ip}: #{spam_reasons.join(', ')}"
      else
        Rails.logger.info "[Lead] SUCCESS - Lead ##{@lead.id} created for #{@property.address}"
      end
      redirect_to property_path(@property), notice: "Thank you! We'll contact you shortly about #{@property.address}."
    else
      Rails.logger.warn "[Lead] FAILED - #{@lead.errors.full_messages.join(', ')}"
      flash.now[:alert] = @lead.errors.full_messages.join(", ")
      render "properties/show", status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "[Lead] EXCEPTION: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    redirect_to property_path(@property), alert: "Something went wrong. Please try again or call us directly."
  end

  private

  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :message, :lead_type)
  end
end
