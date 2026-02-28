class PropertiesController < ApplicationController
  def index
    @properties_scope = Property.in_ocean_city

    apply_filters

    # Sorting
    @sort = params[:sort].presence || "verified_first"
    @properties_scope = apply_sort(@properties_scope)

    @pagy, @properties = pagy(@properties_scope, limit: 48)
    @searching = search_active?

    # Track search impressions for displayed properties (skip bots)
    track_search_impressions(@properties) if @searching && !bot_request?

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def search
    @properties_scope = Property.in_ocean_city

    apply_filters

    # Sorting
    @sort = params[:sort].presence || "verified_first"
    @properties_scope = apply_sort(@properties_scope)

    @pagy, @properties = pagy(@properties_scope, limit: 48)
    @searching = true

    respond_to do |format|
      format.html
      format.turbo_stream { render :index }
    end
  end

  def show
    # Handle old URLs with UUIDs - redirect to clean URL
    if params[:id] =~ /-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
      clean_slug = params[:id].sub(/-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i, '')
      redirect_to property_path(clean_slug), status: :moved_permanently
      return
    end

    @property = Property.friendly.find(params[:id])
    @lead = Lead.new(property: @property)
    @similar_properties = @property.similar_properties(6)

    # Track page view (skip bots)
    track_page_view(@property) unless bot_request?
  rescue ActiveRecord::RecordNotFound
    redirect_to properties_path, alert: "Property not found"
  end

  private

  def apply_filters
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

    # Date-based availability filter (only when no_dates is not checked)
    if params[:no_dates] != "1" && params[:check_in].present? && params[:check_out].present?
      begin
        check_in = Date.parse(params[:check_in])
        check_out = Date.parse(params[:check_out])
        @properties_scope = @properties_scope.available_between(check_in, check_out)
      rescue ArgumentError
        # Invalid date format, skip date filter
      end
    end

    # Price range filter
    if params[:min_price].present? || params[:max_price].present?
      @properties_scope = @properties_scope.in_price_range(params[:min_price], params[:max_price])
    end

    # Price range dropdown (converts to min/max)
    if params[:price_range].present?
      min_price, max_price = parse_price_range(params[:price_range])
      @properties_scope = @properties_scope.in_price_range(min_price, max_price) if min_price || max_price
    end
  end

  def search_active?
    params[:q].present? ||
    params[:neighborhood].present? ||
    params[:verified].present? ||
    params[:sort].present? ||
    params[:bedrooms].present? ||
    params[:bathrooms].present? ||
    params[:sleeps].present? ||
    params[:check_in].present? ||
    params[:check_out].present? ||
    params[:min_price].present? ||
    params[:max_price].present? ||
    params[:price_range].present?
  end

  def parse_price_range(range)
    case range
    when "under_2000"
      [nil, 2000]
    when "2000_4000"
      [2000, 4000]
    when "4000_6000"
      [4000, 6000]
    when "6000_plus"
      [6000, nil]
    else
      [nil, nil]
    end
  end

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
    when "price_low"
      # Sort by lowest weekly rate, nulls last
      scope.order(Arel.sql("(
        SELECT MIN((avail->>'minimum_rate')::numeric)
        FROM jsonb_array_elements(availability) AS avail
        WHERE (avail->>'minimum_rate') IS NOT NULL
      ) ASC NULLS LAST"))
    when "price_high"
      # Sort by highest weekly rate, nulls last
      scope.order(Arel.sql("(
        SELECT MAX((avail->>'maximum_rate')::numeric)
        FROM jsonb_array_elements(availability) AS avail
        WHERE (avail->>'maximum_rate') IS NOT NULL
      ) DESC NULLS LAST"))
    else
      scope.order(is_verified: :desc, address: :asc)
    end
  end

  def track_search_impressions(properties)
    return if properties.empty?

    today = Date.current
    property_ids = properties.map(&:id)

    # Increment search impressions for all displayed properties
    PropertyAnalytic.where(property_id: property_ids, date: today).update_all(
      "search_impressions = search_impressions + 1"
    )

    # Create records for properties that don't have analytics for today
    existing_ids = PropertyAnalytic.where(property_id: property_ids, date: today).pluck(:property_id)
    new_ids = property_ids - existing_ids

    new_ids.each do |property_id|
      PropertyAnalytic.create(
        property_id: property_id,
        date: today,
        search_impressions: 1
      )
    end
  rescue => e
    Rails.logger.error("Failed to track search impressions: #{e.message}")
  end

  def track_page_view(property)
    session_id = session.id.to_s
    today = Date.current

    # Create or update daily analytics
    analytic = PropertyAnalytic.find_or_initialize_by(
      property_id: property.id,
      date: today
    )
    analytic.page_views = (analytic.page_views || 0) + 1

    # Track unique visitors by session
    unless session[:viewed_properties]&.include?(property.id)
      analytic.unique_visitors = (analytic.unique_visitors || 0) + 1
      session[:viewed_properties] ||= []
      session[:viewed_properties] << property.id
    end

    analytic.save
  rescue => e
    Rails.logger.error("Failed to track page view: #{e.message}")
  end

  def bot_request?
    user_agent = request.user_agent.to_s.downcase
    bot_patterns = %w[bot spider crawler googlebot bingbot slurp duckduckbot facebookexternalhit twitterbot]
    bot_patterns.any? { |pattern| user_agent.include?(pattern) }
  end

end
