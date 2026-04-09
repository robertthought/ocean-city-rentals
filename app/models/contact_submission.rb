class ContactSubmission < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :unanswered, -> { where(responded: false) }
  scope :answered, -> { where(responded: true) }
  scope :not_spam, -> { where(spam: false) }
  scope :flagged_spam, -> { where(spam: true) }

  def mark_responded!
    update!(responded: true, responded_at: Time.current)
  end

  def mark_spam!
    update!(spam: true)
  end

  def mark_not_spam!
    update!(spam: false, spam_reason: nil)
  end
end
