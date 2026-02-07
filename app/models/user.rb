class User < ApplicationRecord
  has_secure_password

  has_many :ownership_claims, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :first_name, :last_name, presence: true

  before_save :downcase_email

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def owned_properties
    Property.joins(:ownership_claims)
            .where(ownership_claims: { user_id: id, status: 'approved' })
  end

  def pending_claims
    ownership_claims.pending
  end

  def has_owned_properties?
    ownership_claims.approved.exists?
  end

  # Password reset
  def generate_reset_token!
    update!(
      reset_password_token: SecureRandom.urlsafe_base64(32),
      reset_password_sent_at: Time.current
    )
  end

  def reset_token_valid?
    reset_password_sent_at.present? && reset_password_sent_at > 2.hours.ago
  end

  def clear_reset_token!
    update!(reset_password_token: nil, reset_password_sent_at: nil)
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
