module Owner
  class PropertiesController < BaseController
    before_action :set_property, except: [:index]
    before_action :authorize_property, except: [:index]

    def index
      @properties = current_owner.owned_properties.order(:address)
    end

    def show
      @recent_analytics = PropertyAnalytic.totals_for_property(@property.id, start_date: 7.days.ago.to_date)
    end

    def edit
    end

    def update
      if @property.update(property_params)
        @property.update(owner_customized: true)
        redirect_to owner_property_path(@property), notice: "Property updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def analytics
      @period = (params[:period] || '30').to_i
      start_date = @period.days.ago.to_date

      @daily_analytics = @property.property_analytics
                                  .for_period(start_date, Date.current)
                                  .order(:date)

      @totals = PropertyAnalytic.totals_for_property(@property.id, start_date: start_date)
    end

    private

    def set_property
      @property = Property.friendly.find(params[:id])
    end

    def authorize_property
      unless current_owner.owned_properties.include?(@property)
        redirect_to owner_root_path, alert: "You don't have access to that property."
      end
    end

    def property_params
      params.require(:property).permit(
        :owner_description,
        :owner_pet_friendly,
        :owner_special_notes,
        :owner_rental_type,
        :owner_weekly_rate,
        :owner_nightly_rate,
        :owner_minimum_nights,
        owner_amenities: []
      )
    end
  end
end
