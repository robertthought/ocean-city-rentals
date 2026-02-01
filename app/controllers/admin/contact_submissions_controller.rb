module Admin
  class ContactSubmissionsController < BaseController
    include Pagy::Backend

    def index
      @submissions = ContactSubmission.recent

      if params[:status] == "unanswered"
        @submissions = @submissions.unanswered
      elsif params[:status] == "answered"
        @submissions = @submissions.answered
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

    def export
      @submissions = ContactSubmission.recent

      respond_to do |format|
        format.csv do
          headers["Content-Disposition"] = "attachment; filename=contact-submissions-#{Date.current}.csv"
          headers["Content-Type"] = "text/csv"
        end
      end
    end
  end
end
