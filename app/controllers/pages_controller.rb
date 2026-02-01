class PagesController < ApplicationController
  def about
  end

  def contact
    @contact_submitted = false
  end

  def submit_contact
    @name = params[:name]
    @email = params[:email]
    @phone = params[:phone]
    @message = params[:message]
    @inquiry_type = params[:inquiry_type]

    if @name.present? && @email.present? && @message.present?
      ContactMailer.new_contact(
        name: @name,
        email: @email,
        phone: @phone,
        message: @message,
        inquiry_type: @inquiry_type
      ).deliver_later

      redirect_to contact_path, notice: "Thank you for your message! We'll get back to you within 24 hours."
    else
      flash.now[:alert] = "Please fill in all required fields."
      @contact_submitted = false
      render :contact
    end
  end
end
