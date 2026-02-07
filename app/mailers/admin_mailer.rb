class AdminMailer < ApplicationMailer
  default to: "bob@bobidell.com"

  def new_ownership_claim(claim)
    @claim = claim
    @user = claim.user
    @property = claim.property

    mail(
      subject: "New ownership claim: #{@property.address} by #{@user.full_name}"
    )
  end
end
