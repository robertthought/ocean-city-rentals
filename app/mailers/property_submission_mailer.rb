class PropertySubmissionMailer < ApplicationMailer
  default to: "bob@bobidell.com"

  def new_submission(submission)
    @submission = submission

    mail(
      subject: "New Property Submission: #{submission.property_address}",
      reply_to: submission.email
    )
  end
end
