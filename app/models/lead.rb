class Lead < ApplicationRecord
  belongs_to :property

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :property, presence: true

  # Scopes
  scope :uncontacted, -> { where(contacted: false) }
  scope :recent, -> { order(created_at: :desc) }

  # Mark as contacted
  def mark_contacted!
    update(contacted: true, contacted_at: Time.current)
  end

  # Send notifications
  after_create :send_notification
  after_create :send_slack_notification

  private

  def send_notification
    LeadMailer.new_lead_notification(self).deliver_later
  end

  def send_slack_notification
    SlackNotifier.notify_new_lead(self)
  end
end
