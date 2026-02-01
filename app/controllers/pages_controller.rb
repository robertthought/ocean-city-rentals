class PagesController < ApplicationController
  def about
  end

  def contact
    @contact_submitted = false
  end

  def submit_contact
    @submission = ContactSubmission.new(
      name: params[:name],
      email: params[:email],
      phone: params[:phone],
      message: params[:message],
      inquiry_type: params[:inquiry_type]
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
