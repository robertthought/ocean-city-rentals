class PropertiesController < ApplicationController
  def index
    @properties_scope = Property.in_ocean_city

    # Text search
    if params[:q].present?
      @properties_scope = @properties_scope.search_by_address(params[:q])
    end

    # Neighborhood filter
    if params[:neighborhood].present?
      @neighborhood = Neighborhood.find(params[:neighborhood]) rescue nil
      @properties_scope = @neighborhood.properties if @neighborhood
    end

    # Verified only filter
    if params[:verified] == "1"
      @properties_scope = @properties_scope.verified
    end

    # Bedrooms filter
    if params[:bedrooms].present?
      @properties_scope = @properties_scope.where("bedrooms >= ?", params[:bedrooms].to_i)
    end

    # Bathrooms filter
    if params[:bathrooms].present?
      @properties_scope = @properties_scope.where("bathrooms >= ?", params[:bathrooms].to_i)
    end

    # Sleeps filter
    if params[:sleeps].present?
      @properties_scope = @properties_scope.where("total_sleeps >= ?", params[:sleeps].to_i)
    end

    # Sorting
    @sort = params[:sort].presence || "verified_first"
    @properties_scope = apply_sort(@properties_scope)

    @pagy, @properties = pagy(@properties_scope, limit: 48)
    @searching = params[:q].present? || params[:neighborhood].present? || params[:verified].present? || params[:sort].present? || params[:bedrooms].present? || params[:bathrooms].present? || params[:sleeps].present?
  end

  def show
    @property = Property.friendly.find(params[:id])
    @lead = Lead.new(property: @property)
  rescue ActiveRecord::RecordNotFound
    redirect_to properties_path, alert: "Property not found"
  end

  private

  def apply_sort(scope)
    case @sort
    when "verified_first"
      scope.order(is_verified: :desc, address: :asc)
    when "street_number"
      scope.order(Arel.sql("CAST(NULLIF(REGEXP_REPLACE(address, '[^0-9].*', '', 'g'), '') AS INTEGER) ASC NULLS LAST"))
    when "newest"
      scope.order(created_at: :desc)
    when "address"
      scope.order(:address)
    else
      scope.order(is_verified: :desc, address: :asc)
    end
  end
end
