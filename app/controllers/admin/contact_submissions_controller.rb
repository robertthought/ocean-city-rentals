module Admin
  class ContactSubmissionsController < BaseController
    include Pagy::Backend

    def index
      @submissions = ContactSubmission.recent

      case params[:status]
      when "unanswered"
        @submissions = @submissions.not_spam.unanswered
      when "answered"
        @submissions = @submissions.not_spam.answered
      when "spam"
        @submissions = @submissions.flagged_spam
      else
        @submissions = @submissions.not_spam
      end

      @pagy, @submissions = pagy(@submissions, limit: 25)
    end

    def show
      @submission = ContactSubmission.find(params[:id])
    end

    def mark_responded
      @submission = ContactSubmission.find(params[:id])
      @submission.mark_responded!
      redirect_to admin_contact_submissions_path, notice: "Marked as responded"
    end

    def mark_spam
      @submission = ContactSubmission.find(params[:id])
      @submission.mark_spam!
      redirect_back fallback_location: admin_contact_submissions_path, notice: "Marked as spam"
    end

    def mark_not_spam
      @submission = ContactSubmission.find(params[:id])
      @submission.mark_not_spam!
      redirect_back fallback_location: admin_contact_submissions_path, notice: "Marked as not spam"
    end

    def export
      @submissions = ContactSubmission.recent.not_spam

      respond_to do |format|
        format.csv do
          headers["Content-Disposition"] = "attachment; filename=contact-submissions-#{Date.current}.csv"
          headers["Content-Type"] = "text/csv"
        end
      end
    end
  end
end
