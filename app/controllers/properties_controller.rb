class PropertiesController < ApplicationController
  def index
    @pagy, @properties = pagy(Property.in_ocean_city.order(:address), limit: 50)

    if params[:q].present?
      @pagy, @properties = pagy(
        Property.search_by_address(params[:q]).order(:address),
        limit: 50
      )
    end
  end

  def show
    @property = Property.friendly.find(params[:id])
    @lead = Lead.new(property: @property)
  rescue ActiveRecord::RecordNotFound
    redirect_to properties_path, alert: "Property not found"
  end
end
