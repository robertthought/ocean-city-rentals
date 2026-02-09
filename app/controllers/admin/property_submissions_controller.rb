module Admin
  class PropertySubmissionsController < BaseController
    include Pagy::Backend

    def index
      @submissions = PropertySubmission.recent

      if params[:status] == "pending"
        @submissions = @submissions.pending
      elsif params[:status] == "reviewed"
        @submissions = @submissions.reviewed
      end

      @pagy, @submissions = pagy(@submissions, limit: 25)
    end

    def show
      @submission = PropertySubmission.find(params[:id])
    end

    def mark_reviewed
      @submission = PropertySubmission.find(params[:id])
      @submission.mark_reviewed!
      redirect_to admin_property_submissions_path, notice: "Marked as reviewed"
    end

    def export
      @submissions = PropertySubmission.recent

      respond_to do |format|
        format.csv do
          headers["Content-Disposition"] = "attachment; filename=property-submissions-#{Date.current}.csv"
          headers["Content-Type"] = "text/csv"
        end
      end
    end
  end
end
