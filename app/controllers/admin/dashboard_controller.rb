module Admin
  class DashboardController < BaseController
    def index
      @leads_today = Lead.where("created_at >= ?", Time.current.beginning_of_day).count
      @leads_this_week = Lead.where("created_at >= ?", Time.current.beginning_of_week).count
      @leads_this_month = Lead.where("created_at >= ?", Time.current.beginning_of_month).count
      @leads_total = Lead.count

      @uncontacted_leads = Lead.uncontacted.count
      @recent_leads = Lead.recent.includes(:property).limit(10)

      @properties_count = Property.in_ocean_city.count
      @verified_count = Property.verified.count

      # Contact submissions
      @contact_submissions_total = ContactSubmission.count
      @unanswered_submissions = ContactSubmission.unanswered.count
      @recent_submissions = ContactSubmission.recent.limit(5)

      # Top properties by leads
      @top_properties = Property.joins(:leads)
        .select("properties.*, COUNT(leads.id) as leads_count")
        .group("properties.id")
        .order("leads_count DESC")
        .limit(5)

      # Ownership claims
      @pending_claims = OwnershipClaim.pending.count
    end
  end
end
