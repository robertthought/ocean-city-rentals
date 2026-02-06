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
    amenities.map { |a| a["description"] || a[:description] }.compact
  end

  # From RTR?
  def from_rtr?
    data_source == "realtimerental"
  end
end
