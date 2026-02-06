# Service to sync RealTimeRental properties with local database
#
# Matching strategy:
#   1. Match by RTR reference ID (for previously synced properties)
#   2. Match by normalized address (for existing properties from CSV import)
#   3. Create new property if no match found
#
class RtrPropertySync
  attr_reader :stats

  def initialize
    @api = RealTimeRentalApi.new
    @stats = { updated: 0, created: 0, skipped: 0, errors: 0 }
  end

  # Full sync - fetches entire catalog
  def full_sync
    Rails.logger.info "[RTR Sync] Starting full property sync..."

    properties = @api.fetch_property_catalog
    Rails.logger.info "[RTR Sync] Fetched #{properties.count} properties from RTR"

    sync_properties(properties)

    Rails.logger.info "[RTR Sync] Completed. #{stats_summary}"
    @stats
  end

  # Incremental sync - only properties changed since last sync
  def incremental_sync(since: nil)
    since ||= last_sync_time || 24.hours.ago
    Rails.logger.info "[RTR Sync] Starting incremental sync since #{since}..."

    properties = @api.fetch_change_log(since: since)
    Rails.logger.info "[RTR Sync] Fetched #{properties.count} changed properties from RTR"

    sync_properties(properties)

    Rails.logger.info "[RTR Sync] Completed. #{stats_summary}"
    @stats
  end

  private

  def sync_properties(rtr_properties)
    # Log unique cities for debugging
    cities = rtr_properties.map { |p| p[:city] }.compact.uniq.sort
    Rails.logger.info "[RTR Sync] Cities in feed: #{cities.join(', ')}"

    rtr_properties.each do |rtr_data|
      sync_property(rtr_data)
    rescue StandardError => e
      Rails.logger.error "[RTR Sync] Error syncing property #{rtr_data[:rtr_reference_id]}: #{e.message}"
      @stats[:errors] += 1
    end
  end

  def sync_property(rtr_data)
    # Skip if missing address
    unless rtr_data[:address].present?
      @stats[:skipped] += 1
      return
    end

    # Only sync Ocean City properties
    city = rtr_data[:city].to_s.downcase
    unless city.include?("ocean")
      @stats[:skipped] += 1
      return
    end

    # Normalize city name for database consistency
    rtr_data[:city] = "Ocean City"
    rtr_data[:state] = "NJ"

    # Find existing property
    property = find_existing_property(rtr_data)

    if property
      update_property(property, rtr_data)
      @stats[:updated] += 1
      Rails.logger.info "[RTR Sync] Updated property ID #{property.id}"
    else
      new_property = create_property(rtr_data)
      @stats[:created] += 1
      Rails.logger.info "[RTR Sync] Created property ID #{new_property.id}"
    end
  end

  def find_existing_property(rtr_data)
    # First try RTR reference ID match (for previously synced properties)
    if rtr_data[:rtr_reference_id].present?
      property = Property.find_by(rtr_reference_id: rtr_data[:rtr_reference_id])
      return property if property
    end

    # Then try exact address match (fast)
    property = Property.find_by(address: rtr_data[:address], city: "Ocean City")
    return property if property

    # Then try normalized address match
    normalized = normalize_address(rtr_data[:address])
    Property.where(city: "Ocean City").where("address ILIKE ?", "%#{rtr_data[:address].split.first}%").find_each do |prop|
      if normalize_address(prop.address) == normalized
        return prop
      end
    end

    nil
  end

  def normalize_address(address)
    return "" if address.blank?

    address
      .downcase
      .gsub(/\s+/, " ")
      .gsub(/[.,#]/, "")
      .gsub(/\b(street|st|avenue|ave|road|rd|drive|dr|lane|ln|court|ct|place|pl)\b/, "")
      .gsub(/\b(north|south|east|west|n|s|e|w)\b/, "")
      .strip
  end

  def update_property(property, rtr_data)
    property.update!(
      rtr_reference_id: rtr_data[:rtr_reference_id].presence || property.rtr_reference_id,
      rtr_property_id: rtr_data[:rtr_property_id].presence || property.rtr_property_id,
      description: rtr_data[:description].presence || property.description,
      photos: rtr_data[:photos].present? ? rtr_data[:photos] : property.photos,
      amenities: rtr_data[:amenities].present? ? rtr_data[:amenities] : property.amenities,
      property_name: rtr_data[:property_name].presence || property.property_name,
      bedrooms: rtr_data[:bedrooms].present? && rtr_data[:bedrooms] > 0 ? rtr_data[:bedrooms] : property.bedrooms,
      bathrooms: rtr_data[:bathrooms].present? && rtr_data[:bathrooms] > 0 ? rtr_data[:bathrooms] : property.bathrooms,
      occupancy_limit: rtr_data[:occupancy_limit].present? && rtr_data[:occupancy_limit] > 0 ? rtr_data[:occupancy_limit] : property.occupancy_limit,
      total_sleeps: rtr_data[:total_sleeps].present? && rtr_data[:total_sleeps] > 0 ? rtr_data[:total_sleeps] : property.total_sleeps,
      property_type: rtr_data[:property_type].presence || property.property_type,
      latitude: rtr_data[:latitude].present? && rtr_data[:latitude] != 0 ? rtr_data[:latitude] : property.latitude,
      longitude: rtr_data[:longitude].present? && rtr_data[:longitude] != 0 ? rtr_data[:longitude] : property.longitude,
      virtual_tour_url: rtr_data[:virtual_tour_url].presence || property.virtual_tour_url,
      broker_name: rtr_data[:broker_name].presence || property.broker_name,
      broker_phone: rtr_data[:broker_phone].presence || property.broker_phone,
      broker_email: rtr_data[:broker_email].presence || property.broker_email,
      broker_website: rtr_data[:broker_website].presence || property.broker_website,
      fee_descriptions: rtr_data[:fee_descriptions].presence || property.fee_descriptions,
      rate_description: rtr_data[:rate_description].presence || property.rate_description,
      availability: rtr_data[:availability].present? ? rtr_data[:availability] : property.availability,
      rates: rtr_data[:rates].present? ? rtr_data[:rates] : property.rates,
      is_verified: true,
      data_source: "realtimerental",
      rtr_synced_at: Time.current
    )
  end

  def create_property(rtr_data)
    Property.create!(
      address: rtr_data[:address],
      city: "Ocean City",
      state: "NJ",
      zip: rtr_data[:zip].presence || "08226",
      rtr_reference_id: rtr_data[:rtr_reference_id],
      rtr_property_id: rtr_data[:rtr_property_id],
      property_type: rtr_data[:property_type],
      property_name: rtr_data[:property_name],
      description: rtr_data[:description],
      photos: rtr_data[:photos] || [],
      amenities: rtr_data[:amenities] || [],
      bedrooms: rtr_data[:bedrooms],
      bathrooms: rtr_data[:bathrooms],
      occupancy_limit: rtr_data[:occupancy_limit],
      total_sleeps: rtr_data[:total_sleeps],
      latitude: rtr_data[:latitude],
      longitude: rtr_data[:longitude],
      virtual_tour_url: rtr_data[:virtual_tour_url],
      broker_name: rtr_data[:broker_name],
      broker_phone: rtr_data[:broker_phone],
      broker_email: rtr_data[:broker_email],
      broker_website: rtr_data[:broker_website],
      fee_descriptions: rtr_data[:fee_descriptions],
      rate_description: rtr_data[:rate_description],
      availability: rtr_data[:availability] || [],
      rates: rtr_data[:rates] || [],
      is_verified: true,
      data_source: "realtimerental",
      rtr_synced_at: Time.current
    )
  end

  def last_sync_time
    Property.where.not(rtr_synced_at: nil).maximum(:rtr_synced_at)
  end

  def stats_summary
    "Updated: #{@stats[:updated]}, Created: #{@stats[:created]}, Skipped: #{@stats[:skipped]}, Errors: #{@stats[:errors]}"
  end
end
