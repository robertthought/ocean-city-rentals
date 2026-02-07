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
      respond_to do |format|
        format.html {
          redirect_to property_path(@property),
          notice: "Thank you! Bob Idell will contact you shortly about #{@property.address}."
        }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "lead-form",
            partial: "leads/success",
            locals: { property: @property }
          )
        }
      end
    else
      respond_to do |format|
        format.html {
          render "properties/show", status: :unprocessable_entity
        }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "lead-form",
            partial: "properties/lead_form",
            locals: { property: @property, lead: @lead }
          )
        }
      end
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :message, :lead_type)
  end
end
