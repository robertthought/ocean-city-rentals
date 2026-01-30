class NeighborhoodsController < ApplicationController
  include Pagy::Backend

  def index
    @neighborhoods = Neighborhood.all
  end

  def show
    @neighborhood = Neighborhood.find(params[:id])
    @pagy, @properties = pagy(@neighborhood.properties.order(:address), limit: 24)
  end
end
