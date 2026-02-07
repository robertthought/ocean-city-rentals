class Property < ApplicationRecord
  extend FriendlyId

  friendly_id :address_slug, use: :slugged

  has_many :leads, dependent: :destroy
  has_many :ownership_claims, dependent: :destroy
  has_many :property_events, dependent: :destroy
  has_many :property_analytics, dependent: :destroy
  has_many_attached :owner_photos

  validates :address, presence: true
  validates :city, presence: true
  validates :zip, presence: true
  validates :slug, presence: true, uniqueness: true

  # Search
  include PgSearch::Model
  pg_search_scope :search_by_address,
    against: [:address, :city, :zip],
    using: {
      tsearch: { prefix: true }
    }

  # Scopes
  # Verified = has RTR data (real, synced rental data)
  scope :verified, -> { where(data_source: "realtimerental") }
  scope :in_ocean_city, -> { where(city: 'Ocean City') }
  scope :with_photos, -> { where("jsonb_array_length(photos) > 0") }
  scope :from_rtr, -> { where(data_source: "realtimerental") }

  # Date-based availability - find properties available for given dates
  scope :available_between, ->(check_in, check_out) {
    where(<<-SQL, check_in: check_in, check_out: check_out)
      EXISTS (
        SELECT 1 FROM jsonb_array_elements(availability) AS avail
        WHERE (avail->>'status') = 'Available'
          AND (avail->>'check_in_date')::date <= :check_in
          AND (avail->>'check_out_date')::date >= :check_out
      )
    SQL
  }

  # Price range filter - filter by minimum/maximum weekly rates
  scope :in_price_range, ->(min_price, max_price) {
    conditions = []
    params = {}

    if min_price.present?
      conditions << "(avail->>'minimum_rate')::numeric >= :min_price"
      params[:min_price] = min_price.to_f
    end

    if max_price.present?
      conditions << "(avail->>'maximum_rate')::numeric <= :max_price"
      params[:max_price] = max_price.to_f
    end

    return all if conditions.empty?

    where(<<-SQL, **params)
      EXISTS (
        SELECT 1 FROM jsonb_array_elements(availability) AS avail
        WHERE #{conditions.join(' AND ')}
      )
    SQL
  }

  # Generate SEO-friendly slug
  def address_slug
    "#{address}-#{city}-#{state}-#{zip}".parameterize
  end

  # Generate meta description
  def generate_meta_description
    "#{address}, #{city}, #{state} #{zip}. Contact Bob Idell Real Estate for rental information, availability, and booking for this Ocean City property."
  end

  # Full display address
  def full_address
    "#{address}, #{city}, #{state} #{zip}"
  end

  # Check if has contact info
  def has_owner_contact?
    email_1.present? || phone_1.present?
  end

  # Photo helpers
  def has_photos?
    photos.present? && photos.any?
  end

  def primary_photo_url
    return nil unless has_photos?
    photos.first&.dig("url") || photos.first&.dig(:url)
  end

  def photo_urls
    return [] unless has_photos?
    photos.map { |p| p["url"] || p[:url] }.compact
  end

  def photo_count
    photos&.count || 0
  end

  # Amenity helpers
  def has_amenities?
    amenities.present? && amenities.any?
  end

  # RTR Amenity ID to Name mapping
  RTR_AMENITY_NAMES = {
    110 => "Air Conditioning",
    120 => "Cable TV",
    130 => "Ceiling Fans",
    140 => "Dishwasher",
    150 => "Fireplace",
    160 => "DVD Player",
    170 => "Internet/WiFi",
    180 => "Linens Provided",
    190 => "Telephone",
    200 => "Television",
    210 => "VCR",
    220 => "Stereo",
    230 => "Iron/Ironing Board",
    240 => "Hair Dryer",
    250 => "Towels Provided",
    260 => "High Chair",
    270 => "Crib",
    280 => "Baby Equipment",
    290 => "Games",
    300 => "Books",
    310 => "Ocean View",
    320 => "Washer",
    330 => "Dryer",
    340 => "Microwave",
    350 => "Coffee Maker",
    360 => "Toaster",
    370 => "Blender",
    380 => "Ice Maker",
    390 => "Cooking Utensils",
    400 => "Dishes & Silverware",
    410 => "Pots & Pans",
    420 => "Deck/Patio",
    430 => "Outdoor Furniture",
    431 => "Balcony",
    440 => "Grill/BBQ",
    450 => "Outdoor Shower",
    460 => "Private Pool",
    470 => "Shared Pool",
    480 => "Hot Tub",
    490 => "Beach Chairs",
    500 => "Beach Umbrella",
    510 => "Beach Badges",
    520 => "Bicycles",
    530 => "Kayak/Canoe",
    540 => "Boat Dock",
    550 => "Fishing Equipment",
    560 => "Tennis Court",
    570 => "Golf Course",
    580 => "Gym/Fitness",
    590 => "Elevator",
    600 => "Wheelchair Accessible",
    610 => "Parking",
    620 => "Garage",
    630 => "Pets Allowed",
    640 => "No Smoking",
    650 => "Central Heat",
    660 => "Gas Heat",
    670 => "Electric Heat",
    680 => "Waterfront",
    690 => "Bay View",
    700 => "City View",
    710 => "Garden View",
    720 => "Pool View"
  }.freeze

  def amenity_list
    return [] unless has_amenities?
    amenities.map { |a|
      id = a["id"] || a[:id]
      # Try to get name from our mapping, fall back to label/description
      RTR_AMENITY_NAMES[id.to_i] ||
      a["description"].presence || a[:description].presence ||
      a["label"].presence || a[:label].presence
    }.compact.uniq
  end

  # From RTR?
  def from_rtr?
    data_source == "realtimerental"
  end

  # Override is_verified to be based on RTR data
  # Properties with RTR data are considered verified (real, active listings)
  def is_verified
    from_rtr?
  end

  # Availability helpers
  def has_availability?
    availability.present? && availability.any?
  end

  # Returns available date ranges (not booked dates)
  def available_periods
    return [] unless has_availability?
    availability.map do |avail|
      {
        check_in: avail["check_in_date"] || avail[:check_in_date],
        check_out: avail["check_out_date"] || avail[:check_out_date],
        status: avail["status"] || avail[:status],
        avg_rate: avail["average_rate"] || avail[:average_rate],
        min_rate: avail["minimum_rate"] || avail[:minimum_rate],
        max_rate: avail["maximum_rate"] || avail[:maximum_rate]
      }
    end
  end

  # For calendar display - returns dates that are available
  def available_dates
    return [] unless has_availability?
    dates = []
    availability.each do |avail|
      next unless (avail["status"] || avail[:status]) == "Available"
      start_date = Date.parse(avail["check_in_date"] || avail[:check_in_date]) rescue nil
      end_date = Date.parse(avail["check_out_date"] || avail[:check_out_date]) rescue nil
      next unless start_date && end_date
      (start_date..end_date).each { |d| dates << d.to_s }
    end
    dates.uniq
  end

  # Rates helpers
  def has_rates?
    rates.present? && rates.any?
  end

  def rate_periods
    return [] unless has_rates?
    rates.map do |rate|
      {
        description: rate["description"] || rate[:description],
        rules: rate["rules"] || rate[:rules],
        rate: rate["rate"] || rate[:rate],
        check_in_date: rate["check_in_date"] || rate[:check_in_date],
        check_out_date: rate["check_out_date"] || rate[:check_out_date],
        daily_rate: rate["daily_rate"] || rate[:daily_rate],
        minimum_stay: rate["minimum_stay"] || rate[:minimum_stay]
      }
    end
  end

  # Get weekly rates only (minimum_stay >= 7)
  def weekly_rates
    rate_periods.select { |r| r[:minimum_stay].to_i >= 7 }
  end

  # Get lowest available weekly rate from availability or rates data
  def lowest_weekly_rate
    # Try availability data first (has minimum_rate)
    if has_availability?
      avail_rates = availability.map { |a|
        (a["minimum_rate"] || a[:minimum_rate])&.to_f
      }.compact.reject(&:zero?)
      return avail_rates.min if avail_rates.any?
    end

    # Fall back to rates data
    if has_rates?
      rate_values = rates.map { |r|
        (r["rate"] || r[:rate])&.to_f
      }.compact.reject(&:zero?)
      return rate_values.min if rate_values.any?
    end

    nil
  end

  # Get highest available weekly rate
  def highest_weekly_rate
    if has_availability?
      avail_rates = availability.map { |a|
        (a["maximum_rate"] || a[:maximum_rate])&.to_f
      }.compact.reject(&:zero?)
      return avail_rates.max if avail_rates.any?
    end

    if has_rates?
      rate_values = rates.map { |r|
        (r["rate"] || r[:rate])&.to_f
      }.compact.reject(&:zero?)
      return rate_values.max if rate_values.any?
    end

    nil
  end

  # Check if property has pricing info
  def has_pricing?
    lowest_weekly_rate.present?
  end

  # Format price range for display
  def price_range_display
    low = lowest_weekly_rate
    high = highest_weekly_rate
    return nil unless low

    if high && high > low
      "$#{low.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}-$#{high.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}/Week"
    else
      "From $#{low.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}/Week"
    end
  end

  # Owner helpers
  def has_approved_owner?
    ownership_claims.approved.exists?
  end

  def current_owner
    ownership_claims.approved.includes(:user).first&.user
  end

  def claimed_by?(user)
    return false unless user
    ownership_claims.where(user: user).exists?
  end

  # Owner contact info (for admin verification)
  def owner_emails
    [email_1, email_2, email_3, email_4].compact.reject(&:blank?)
  end

  def owner_phones
    [phone_1, phone_2, phone_3, phone_4].compact.reject(&:blank?)
  end

  # Display description: owner override or RTR
  def display_description
    owner_description.presence || description
  end

  # All photos combined: RTR + owner uploads
  def all_photo_urls
    rtr_urls = photo_urls
    uploaded_urls = owner_photos.map { |photo| Rails.application.routes.url_helpers.rails_blob_path(photo, only_path: true) }
    rtr_urls + uploaded_urls
  end

  def total_photo_count
    (photos&.count || 0) + owner_photos.count
  end
end
