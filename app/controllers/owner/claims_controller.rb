module Owner
  class ClaimsController < BaseController
    def index
      @claims = current_owner.ownership_claims.includes(:property).recent
    end

    def new
      @claim = OwnershipClaim.new
      @properties = []

      # Pre-select property if coming from property page
      if params[:property_id].present?
        @selected_property = Property.find_by(id: params[:property_id])
      end
    end

    def search_properties
      query = params[:q].to_s.strip

      if query.length >= 2
        @properties = Property.in_ocean_city
                             .search_by_address(query)
                             .limit(20)

        # Exclude already claimed by this user
        claimed_ids = current_owner.ownership_claims.pluck(:property_id)
        @properties = @properties.where.not(id: claimed_ids) if claimed_ids.any?
      else
        @properties = []
      end

      respond_to do |format|
        format.turbo_stream
        format.html { render :new }
      end
    end

    def create
      @property = Property.find(params[:property_id])

      # Check if already claimed by this user
      if current_owner.ownership_claims.exists?(property_id: @property.id)
        redirect_to owner_claims_path, alert: "You have already submitted a claim for this property."
        return
      end

      @claim = current_owner.ownership_claims.build(
        property: @property,
        verification_notes: params[:verification_notes]
      )

      if @claim.save
        # Notify admin
        AdminMailer.new_ownership_claim(@claim).deliver_later
        redirect_to owner_claims_path, notice: "Your claim for #{@property.address} has been submitted for review."
      else
        @properties = []
        render :new, status: :unprocessable_entity
      end
    end
  end
end
