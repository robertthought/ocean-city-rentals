module Owner
  class DashboardController < BaseController
    def index
      @properties = current_owner.owned_properties.order(:address)
      @pending_claims = current_owner.pending_claims.includes(:property).recent

      # Aggregate analytics for all owned properties (30 days)
      property_ids = @properties.pluck(:id)

      if property_ids.any?
        totals = PropertyAnalytic.totals_for_properties(property_ids)
        @total_views_30d = totals[:total_views]
        @total_impressions_30d = totals[:total_impressions]
      else
        @total_views_30d = 0
        @total_impressions_30d = 0
      end
    end
  end
end
