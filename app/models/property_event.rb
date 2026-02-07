class PropertyEvent < ApplicationRecord
  belongs_to :property

  validates :event_type, inclusion: { in: %w[page_view search_impression] }

  scope :page_views, -> { where(event_type: 'page_view') }
  scope :search_impressions, -> { where(event_type: 'search_impression') }
  scope :since, ->(date) { where('created_at >= ?', date) }

  # Bulk insert for search impressions (more efficient)
  def self.track_search_impressions(property_ids, session_id:, ip_address:)
    return if property_ids.empty?

    events = property_ids.map do |id|
      {
        property_id: id,
        event_type: 'search_impression',
        session_id: session_id,
        ip_address: ip_address,
        created_at: Time.current
      }
    end

    insert_all(events)
  end
end
