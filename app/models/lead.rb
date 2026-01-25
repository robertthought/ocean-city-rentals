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

  # Send notification email (implement later)
  after_create :send_notification

  private

  def send_notification
    # TODO: Send email to Bob with lead details
    # LeadMailer.new_lead(self).deliver_later
  end
end
