class ContactSubmission < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :unanswered, -> { where(responded: false) }
  scope :answered, -> { where(responded: true) }

  def mark_responded!
    update!(responded: true, responded_at: Time.current)
  end
end
