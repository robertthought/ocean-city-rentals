# Blog articles for SEO content marketing
# These are database-backed for easy admin management

class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Scopes
  scope :published, -> { where(published: true).where("published_at <= ?", Time.current) }
  scope :draft, -> { where(published: false) }
  scope :recent, -> { order(published_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }

  # Validations
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :content, presence: true
  validates :meta_description, length: { maximum: 160 }, allow_blank: true

  # Callbacks
  before_validation :set_published_at, if: -> { published? && published_at.blank? }
  before_save :generate_excerpt, if: -> { excerpt.blank? && content.present? }

  # Categories for blog organization
  CATEGORIES = [
    "Beach Guide",
    "Events",
    "Food & Dining",
    "Activities",
    "Travel Tips",
    "Local News",
    "Vacation Planning"
  ].freeze

  def to_param
    slug
  end

  def reading_time
    words_per_minute = 200
    words = content.to_s.split.size
    minutes = (words / words_per_minute.to_f).ceil
    "#{minutes} min read"
  end

  def tag_list
    tags.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def tag_list=(value)
    self.tags = value.is_a?(Array) ? value.join(", ") : value
  end

  def formatted_published_date
    published_at&.strftime("%B %d, %Y")
  end

  def og_image
    featured_image_url.presence || "https://ocnjweeklyrentals.com/og-default.jpg"
  end

  private

  def set_published_at
    self.published_at = Time.current
  end

  def generate_excerpt
    # Strip HTML and take first 160 characters
    plain_text = content.to_s.gsub(/<[^>]*>/, "").gsub(/\s+/, " ").strip
    self.excerpt = plain_text.truncate(160)
  end

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end
end
