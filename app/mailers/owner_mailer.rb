class OwnerMailer < ApplicationMailer
  def claim_approved(claim)
    @claim = claim
    @user = claim.user
    @property = claim.property

    mail(
      to: @user.email,
      subject: "Your ownership claim for #{@property.address} has been approved!"
    )
  end

  def claim_rejected(claim)
    @claim = claim
    @user = claim.user
    @property = claim.property

    mail(
      to: @user.email,
      subject: "Update on your ownership claim for #{@property.address}"
    )
  end

  def password_reset(user)
    @user = user
    @reset_url = owner_reset_password_url(@user.reset_password_token)

    mail(
      to: @user.email,
      subject: "Reset your OCNJ Weekly Rentals password"
    )
  end
end
