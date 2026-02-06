class Property < ApplicationRecord
  extend FriendlyId

  friendly_id :address_slug, use: :slugged

  has_many :leads, dependent: :destroy

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
  scope :verified, -> { where(is_verified: true) }
  scope :in_ocean_city, -> { where(city: 'Ocean City') }
  scope :with_photos, -> { where("jsonb_array_length(photos) > 0") }
  scope :from_rtr, -> { where(data_source: "realtimerental") }

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
end
