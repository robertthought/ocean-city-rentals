class RentalRequestMailer < ApplicationMailer
  default from: "OCNJ Weekly Rentals <rentals@ocnjweeklyrentals.com>"

  def new_request_notification(rental_request)
    @rental_request = rental_request
    mail(
      to: "rentals@ocnjweeklyrentals.com",
      subject: "New Rental Request from #{rental_request.name}"
    )
  end

  def confirmation_to_guest(rental_request)
    @rental_request = rental_request
    mail(
      to: rental_request.email,
      subject: "We Received Your Rental Request - OCNJ Weekly Rentals"
    )
  end
end
