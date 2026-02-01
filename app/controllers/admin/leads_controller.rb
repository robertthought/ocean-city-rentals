module Admin
  class LeadsController < BaseController
    include Pagy::Backend

    def index
      @leads = Lead.recent.includes(:property)

      if params[:status] == "uncontacted"
        @leads = @leads.uncontacted
      elsif params[:status] == "contacted"
        @leads = @leads.where(contacted: true)
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

    def export
      @leads = Lead.recent.includes(:property)

      respond_to do |format|
        format.csv do
          headers["Content-Disposition"] = "attachment; filename=leads-#{Date.current}.csv"
          headers["Content-Type"] = "text/csv"
        end
      end
    end
  end
end
