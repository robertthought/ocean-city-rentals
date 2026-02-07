module Owner
  class PropertyPhotosController < BaseController
    before_action :set_property
    before_action :authorize_property

    def create
      if params[:photos].present?
        @property.owner_photos.attach(params[:photos])
        @property.update(owner_customized: true)
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_owner_property_path(@property), notice: "Photos uploaded successfully." }
      end
    end

    def destroy
      photo = @property.owner_photos.find(params[:id])
      photo.purge_later

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_owner_property_path(@property), notice: "Photo removed." }
      end
    end

    private

    def set_property
      @property = Property.friendly.find(params[:property_id])
    end

    def authorize_property
      unless current_owner.owned_properties.include?(@property)
        redirect_to owner_root_path, alert: "You don't have access to that property."
      end
    end
  end
end
