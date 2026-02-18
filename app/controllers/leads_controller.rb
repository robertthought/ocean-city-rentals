class LeadsController < ApplicationController
  def create
    @property = Property.friendly.find(params[:property_id])

    # Verify reCAPTCHA
    recaptcha_result = RecaptchaVerifier.verify(params[:recaptcha_token], request.remote_ip)
    unless recaptcha_result[:success]
      Rails.logger.warn "[Lead] reCAPTCHA failed for #{request.remote_ip}: #{recaptcha_result}"
      redirect_to property_path(@property), alert: "Verification failed. Please try again."
      return
    end

    @lead = @property.leads.new(lead_params)
    @lead.ip_address = request.remote_ip
    @lead.user_agent = request.user_agent
    @lead.source = params[:source] || 'direct'
    @lead.recaptcha_score = recaptcha_result[:score]

    if @lead.save
      redirect_to property_path(@property), notice: "Thank you! We'll contact you shortly about #{@property.address}."
    else
      # Re-render property page with form errors
      flash.now[:alert] = @lead.errors.full_messages.join(", ")
      render "properties/show", status: :unprocessable_entity
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :message, :lead_type)
  end
end
