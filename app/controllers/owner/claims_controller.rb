module Owner
  class ClaimsController < BaseController
    skip_before_action :require_owner_login, only: [:claim_property, :create_claim_with_registration]

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
        # Try pg_search first
        @properties = Property.in_ocean_city
                             .search_by_address(query)
                             .limit(20)

        # Fallback to ILIKE if no results (handles typos better)
        if @properties.empty?
          search_term = "%#{query.gsub(/\s+/, '%')}%"
          @properties = Property.in_ocean_city
                               .where("address ILIKE ? OR CONCAT(address, ' ', city) ILIKE ?", search_term, search_term)
                               .order(:address)
                               .limit(20)
        end

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

    # Public claim page - shows property + registration form
    def claim_property
      @property = Property.find(params[:id])

      # If already logged in, redirect to regular claim flow
      if current_owner
        redirect_to new_owner_claim_path(property_id: @property.id)
        return
      end

      render layout: 'owner_auth'
    end

    # Handle registration + claim in one step
    def create_claim_with_registration
      @property = Property.find(params[:id])

      # Create user
      @user = User.new(
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email]&.downcase,
        phone: params[:phone],
        password: params[:password]
      )

      if @user.save
        # Log them in
        session[:owner_id] = @user.id

        # Create the claim
        @claim = @user.ownership_claims.create(
          property: @property,
          verification_notes: params[:verification_notes]
        )

        # Notify admin
        AdminMailer.new_ownership_claim(@claim).deliver_later

        redirect_to owner_claims_path, notice: "Welcome! Your claim for #{@property.address} has been submitted for review."
      else
        flash.now[:alert] = @user.errors.full_messages.join(", ")
        render :claim_property, layout: 'owner_auth', status: :unprocessable_entity
      end
    end

    private

    def current_owner
      @current_owner ||= User.find_by(id: session[:owner_id]) if session[:owner_id]
    end
    helper_method :current_owner
  end
end
