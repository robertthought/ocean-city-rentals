module Admin
  class AnalyticsController < BaseController
    def index
      @period = params[:period] || "30"
      @start_date = @period.to_i.days.ago.to_date
      @end_date = Date.current

      # Overall stats
      @total_views = PropertyAnalytic
        .where(date: @start_date..@end_date)
        .sum(:page_views)

      @total_impressions = PropertyAnalytic
        .where(date: @start_date..@end_date)
        .sum(:search_impressions)

      @total_unique_visitors = PropertyAnalytic
        .where(date: @start_date..@end_date)
        .sum(:unique_visitors)

      # Top properties by page views
      @top_properties = Property
        .joins(:property_analytics)
        .where(property_analytics: { date: @start_date..@end_date })
        .select(
          "properties.*",
          "SUM(property_analytics.page_views) as total_views",
          "SUM(property_analytics.search_impressions) as total_impressions",
          "SUM(property_analytics.unique_visitors) as total_unique_visitors"
        )
        .group("properties.id")
        .order("total_views DESC")
        .limit(50)

      # Daily trend data for chart
      @daily_views = PropertyAnalytic
        .where(date: @start_date..@end_date)
        .group(:date)
        .order(:date)
        .sum(:page_views)
    end
  end
end
