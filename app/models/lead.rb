class Lead < ApplicationRecord
  belongs_to :property

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :property, presence: true

  scope :uncontacted, -> { where(contacted: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :not_spam, -> { where(spam: false) }
  scope :flagged_spam, -> { where(spam: true) }

  after_create :send_notification, unless: :spam?
  after_create :send_slack_notification, unless: :spam?

  def mark_contacted!
    update(contacted: true, contacted_at: Time.current)
  end

  def mark_spam!
    update!(spam: true)
  end

  def mark_not_spam!
    update!(spam: false, spam_reason: nil)
  end

  private

  def send_notification
    LeadMailer.new_lead_notification(self).deliver_now
  rescue StandardError => e
    Rails.logger.error "[Lead] Email notification failed: #{e.message}"
  end

  def send_slack_notification
    SlackNotifier.notify_new_lead(self)
  rescue StandardError => e
    Rails.logger.error "[Lead] Slack notification failed: #{e.message}"
  end
end
