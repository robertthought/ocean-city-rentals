class RentalRequest < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :bedrooms, numericality: { greater_than: 0, allow_nil: true }
  validates :bathrooms, numericality: { greater_than: 0, allow_nil: true }
  validates :sleeps, numericality: { greater_than: 0, allow_nil: true }

  scope :uncontacted, -> { where(contacted: false) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_contacted!
    update(contacted: true, contacted_at: Time.current)
  end

  after_create :send_notifications

  private

  def send_notifications
    RentalRequestMailer.new_request_notification(self).deliver_later
    RentalRequestMailer.confirmation_to_guest(self).deliver_later
    SlackNotifier.notify_rental_request(self)
  rescue StandardError => e
    Rails.logger.error "[RentalRequest] Notification failed: #{e.message}"
  end
end
