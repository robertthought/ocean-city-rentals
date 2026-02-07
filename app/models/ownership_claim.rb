class OwnershipClaim < ApplicationRecord
  belongs_to :user
  belongs_to :property

  validates :user_id, uniqueness: { scope: :property_id,
            message: "has already claimed this property" }
  validates :status, inclusion: { in: %w[pending approved rejected] }
  validates :verification_notes, presence: true

  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :recent, -> { order(created_at: :desc) }

  def pending?
    status == 'pending'
  end

  def approved?
    status == 'approved'
  end

  def rejected?
    status == 'rejected'
  end

  def approve!(admin_notes: nil, reviewed_by: nil)
    update!(
      status: 'approved',
      admin_notes: admin_notes,
      reviewed_at: Time.current,
      reviewed_by: reviewed_by
    )
  end

  def reject!(admin_notes:, reviewed_by: nil)
    update!(
      status: 'rejected',
      admin_notes: admin_notes,
      reviewed_at: Time.current,
      reviewed_by: reviewed_by
    )
  end
end
