module Admin
  class LeadsController < BaseController
    include Pagy::Backend

    def index
      @leads = Lead.recent.includes(:property)

      case params[:status]
      when "uncontacted"
        @leads = @leads.not_spam.uncontacted
      when "contacted"
        @leads = @leads.not_spam.where(contacted: true)
      when "spam"
        @leads = @leads.flagged_spam
      else
        @leads = @leads.not_spam
      end

      @pagy, @leads = pagy(@leads, limit: 25)
    end

    def show
      @lead = Lead.find(params[:id])
    end

    def mark_contacted
      @lead = Lead.find(params[:id])
      @lead.mark_contacted!
      redirect_to admin_leads_path, notice: "Lead marked as contacted"
    end

    def mark_spam
      @lead = Lead.find(params[:id])
      @lead.mark_spam!
      redirect_back fallback_location: admin_leads_path, notice: "Marked as spam"
    end

    def mark_not_spam
      @lead = Lead.find(params[:id])
      @lead.mark_not_spam!
      redirect_back fallback_location: admin_leads_path, notice: "Marked as not spam"
    end

    def destroy
      @lead = Lead.find(params[:id])
      @lead.destroy
      redirect_to admin_leads_path, notice: "Lead deleted"
    end

    def export
      @leads = Lead.recent.not_spam.includes(:property)

      respond_to do |format|
        format.csv do
          headers["Content-Disposition"] = "attachment; filename=leads-#{Date.current}.csv"
          headers["Content-Type"] = "text/csv"
        end
      end
    end
  end
end
