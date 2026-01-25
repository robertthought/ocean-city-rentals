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
end
