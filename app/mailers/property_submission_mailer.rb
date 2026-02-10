class PropertySubmissionMailer < ApplicationMailer
  default to: "rentals@ocnjweeklyrentals.com"

  def new_submission(submission)
    @submission = submission

    mail(
      subject: "New Property Submission: #{submission.property_address}",
      reply_to: submission.email
    )
  end
end
