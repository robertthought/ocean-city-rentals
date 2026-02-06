class ContactMailer < ApplicationMailer
  default to: "bob@bobidell.com"

  def new_contact(name:, email:, phone:, message:, inquiry_type:)
    @name = name
    @email = email
    @phone = phone
    @message = message
    @inquiry_type = inquiry_type

    mail(
      subject: "New Contact: #{inquiry_type || 'General Inquiry'} - #{name}",
      reply_to: email
    )
  end
end
