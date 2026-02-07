class PropertyAnalytic < ApplicationRecord
  belongs_to :property

  scope :for_period, ->(start_date, end_date) {
    where(date: start_date..end_date)
  }

  def self.totals_for_property(property_id, start_date: 30.days.ago.to_date, end_date: Date.current)
    result = where(property_id: property_id, date: start_date..end_date)
      .select(
        'COALESCE(SUM(page_views), 0) as total_views',
        'COALESCE(SUM(search_impressions), 0) as total_impressions',
        'COALESCE(SUM(unique_visitors), 0) as total_unique_visitors'
      ).first

    {
      total_views: result.total_views.to_i,
      total_impressions: result.total_impressions.to_i,
      total_unique_visitors: result.total_unique_visitors.to_i
    }
  end

  def self.totals_for_properties(property_ids, start_date: 30.days.ago.to_date, end_date: Date.current)
    return { total_views: 0, total_impressions: 0 } if property_ids.empty?

    result = where(property_id: property_ids, date: start_date..end_date)
      .select(
        'COALESCE(SUM(page_views), 0) as total_views',
        'COALESCE(SUM(search_impressions), 0) as total_impressions'
      ).first

    {
      total_views: result.total_views.to_i,
      total_impressions: result.total_impressions.to_i
    }
  end
end
