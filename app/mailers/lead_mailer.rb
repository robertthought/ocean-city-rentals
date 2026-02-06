class LeadMailer < ApplicationMailer
  default to: "bob@bobidell.com"

  def new_lead_notification(lead)
    @lead = lead
    @property = lead.property

    mail(
      subject: "New Lead: #{@property.address} - #{@lead.name}",
      reply_to: @lead.email
    )
  end
end
