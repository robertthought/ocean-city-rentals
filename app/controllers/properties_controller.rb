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

    @pagy, @properties = pagy(@properties_scope.order(:address), limit: 48)
    @searching = params[:q].present? || params[:neighborhood].present? || params[:verified].present?
  end

  def show
    @property = Property.friendly.find(params[:id])
    @lead = Lead.new(property: @property)
  rescue ActiveRecord::RecordNotFound
    redirect_to properties_path, alert: "Property not found"
  end
end
