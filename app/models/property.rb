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

  def amenity_list
    return [] unless has_amenities?
    amenities.map { |a|
      a["description"].presence || a[:description].presence ||
      a["label"].presence || a[:label].presence
    }.compact
  end

  # From RTR?
  def from_rtr?
    data_source == "realtimerental"
  end

  # Availability helpers
  def has_availability?
    availability.present? && availability.any?
  end

  def booked_dates
    return [] unless has_availability?
    dates = []
    availability.each do |booking|
      start_date = Date.parse(booking["start_date"] || booking[:start_date]) rescue nil
      end_date = Date.parse(booking["end_date"] || booking[:end_date]) rescue nil
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
        name: rate["name"] || rate[:name],
        start_date: rate["start_date"] || rate[:start_date],
        end_date: rate["end_date"] || rate[:end_date],
        weekly_rate: rate["weekly_rate"] || rate[:weekly_rate],
        daily_rate: rate["daily_rate"] || rate[:daily_rate],
        minimum_stay: rate["minimum_stay"] || rate[:minimum_stay]
      }
    end
  end
end
