class PropertySubmission < ApplicationRecord
  validates :owner_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :property_address, presence: true
  validates :bedrooms, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :bathrooms, numericality: { only_integer: true, greater_than: 0, allow_blank: true }

  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(reviewed: false) }
  scope :reviewed, -> { where(reviewed: true) }

  def mark_reviewed!
    update!(reviewed: true, reviewed_at: Time.current)
  end

  def full_address
    parts = [property_address]
    parts << city if city.present?
    parts << state if state.present?
    parts << zip if zip.present?
    parts.join(", ")
  end
end
