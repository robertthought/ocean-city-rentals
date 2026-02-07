module Admin
  class OwnershipClaimsController < BaseController
    include Pagy::Backend

    def index
      @claims = OwnershipClaim.includes(:user, :property)

      case params[:status]
      when 'pending'
        @claims = @claims.pending
      when 'approved'
        @claims = @claims.approved
      when 'rejected'
        @claims = @claims.rejected
      end

      @claims = @claims.recent
      @pagy, @claims = pagy(@claims, limit: 25)
    end

    def show
      @claim = OwnershipClaim.includes(:user, :property).find(params[:id])
      @property = @claim.property
      @user = @claim.user
    end

    def approve
      @claim = OwnershipClaim.find(params[:id])
      @claim.approve!(
        admin_notes: params[:admin_notes],
        reviewed_by: "admin"
      )

      OwnerMailer.claim_approved(@claim).deliver_later
      redirect_to admin_ownership_claims_path, notice: "Claim approved. Owner has been notified."
    end

    def reject
      @claim = OwnershipClaim.find(params[:id])
      @claim.reject!(
        admin_notes: params[:admin_notes],
        reviewed_by: "admin"
      )

      OwnerMailer.claim_rejected(@claim).deliver_later
      redirect_to admin_ownership_claims_path, notice: "Claim rejected. Owner has been notified."
    end
  end
end
