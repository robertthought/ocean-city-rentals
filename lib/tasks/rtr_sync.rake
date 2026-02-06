namespace :rtr do
  desc "Test RealTimeRental API connection"
  task test: :environment do
    puts "Testing RTR API connection..."
    api = RealTimeRentalApi.new
    if api.hello_world
      puts "✓ API connection successful!"
    else
      puts "✗ API connection failed"
      exit 1
    end
  end

  desc "Full sync of properties from RealTimeRental"
  task sync: :environment do
    puts "Starting full RTR property sync..."
    sync = RtrPropertySync.new
    stats = sync.full_sync
    puts "Sync complete!"
    puts "  Updated: #{stats[:updated]}"
    puts "  Created: #{stats[:created]}"
    puts "  Skipped: #{stats[:skipped]}"
    puts "  Errors:  #{stats[:errors]}"
  end

  desc "Incremental sync of recently changed properties from RealTimeRental"
  task sync_changes: :environment do
    hours = ENV.fetch("HOURS", 24).to_i
    since = hours.hours.ago
    puts "Starting incremental RTR sync for changes since #{since}..."
    sync = RtrPropertySync.new
    stats = sync.incremental_sync(since: since)
    puts "Sync complete!"
    puts "  Updated: #{stats[:updated]}"
    puts "  Created: #{stats[:created]}"
    puts "  Skipped: #{stats[:skipped]}"
    puts "  Errors:  #{stats[:errors]}"
  end

  desc "Fetch and display sample property data from RTR (for debugging)"
  task sample: :environment do
    puts "Fetching sample data from RTR..."
    api = RealTimeRentalApi.new
    properties = api.fetch_property_catalog

    puts "Found #{properties.count} properties"

    # Show first 5 properties with all data
    properties.first(5).each_with_index do |sample, i|
      puts "\n--- Property #{i + 1} ---"
      puts "  Reference ID: #{sample[:rtr_reference_id].inspect}"
      puts "  Property ID: #{sample[:rtr_property_id].inspect}"
      puts "  Is Active: #{sample[:is_active].inspect}"
      puts "  Address: #{sample[:address].inspect}"
      puts "  City: #{sample[:city].inspect}"
      puts "  State: #{sample[:state].inspect}"
      puts "  Zip: #{sample[:zip].inspect}"
      puts "  Bedrooms: #{sample[:bedrooms].inspect}"
      puts "  Baths: #{sample[:bathrooms].inspect}"
      puts "  Photos count: #{sample[:photos]&.count || 0}"
      puts "  Amenities count: #{sample[:amenities]&.count || 0}"
      puts "  Broker: #{sample[:broker_name].inspect}"
      puts "  Description: #{sample[:description]&.to_s&.slice(0, 100).inspect}..."

      if sample[:photos]&.any?
        puts "  First photo: #{sample[:photos].first[:url]}"
      end
    end

    # Count by city
    puts "\n--- City breakdown ---"
    city_counts = properties.group_by { |p| p[:city] }.transform_values(&:count)
    city_counts.sort_by { |_, v| -v }.each do |city, count|
      puts "  #{city || 'nil'}: #{count}"
    end

    # Count with/without addresses
    with_addr = properties.count { |p| p[:address].present? }
    puts "\n--- Address stats ---"
    puts "  With address: #{with_addr}"
    puts "  Without address: #{properties.count - with_addr}"
  end

  desc "Debug RTR data - show amenities, rates, availability for sample properties"
  task debug: :environment do
    puts "Fetching sample data from RTR to debug amenities/rates/availability..."
    api = RealTimeRentalApi.new
    properties = api.fetch_property_catalog

    # Find Ocean City properties with data
    oc_properties = properties.select { |p| p[:city].to_s.downcase.include?("ocean") }
    puts "Found #{oc_properties.count} Ocean City properties"

    # Show detailed amenities/rates/availability for first 3
    oc_properties.first(3).each_with_index do |sample, i|
      puts "\n" + "="*60
      puts "Property #{i + 1}: #{sample[:address]}"
      puts "="*60

      puts "\n--- AMENITIES (#{sample[:amenities]&.count || 0}) ---"
      if sample[:amenities]&.any?
        sample[:amenities].first(10).each do |a|
          puts "  ID: #{a[:id]}, Label: #{a[:label].inspect}, Value: #{a[:value].inspect}, Desc: #{a[:description].inspect}"
        end
      else
        puts "  (none)"
      end

      puts "\n--- RATES (#{sample[:rates]&.count || 0}) ---"
      if sample[:rates]&.any?
        sample[:rates].each do |r|
          puts "  #{r.inspect}"
        end
      else
        puts "  (none)"
      end

      puts "\n--- AVAILABILITY (#{sample[:availability]&.count || 0}) ---"
      if sample[:availability]&.any?
        sample[:availability].first(5).each do |a|
          puts "  #{a.inspect}"
        end
      else
        puts "  (none)"
      end

      puts "\n--- RATE DESCRIPTION ---"
      puts "  #{sample[:rate_description].inspect}"

      puts "\n--- FEE DESCRIPTIONS ---"
      puts "  #{sample[:fee_descriptions].inspect}"
    end

    # Summary stats
    puts "\n" + "="*60
    puts "SUMMARY STATS"
    puts "="*60
    with_amenities = oc_properties.count { |p| p[:amenities]&.any? }
    with_rates = oc_properties.count { |p| p[:rates]&.any? }
    with_availability = oc_properties.count { |p| p[:availability]&.any? }
    with_rate_desc = oc_properties.count { |p| p[:rate_description].present? }

    puts "Properties with amenities: #{with_amenities}/#{oc_properties.count}"
    puts "Properties with rates: #{with_rates}/#{oc_properties.count}"
    puts "Properties with availability: #{with_availability}/#{oc_properties.count}"
    puts "Properties with rate_description: #{with_rate_desc}/#{oc_properties.count}"
  end

  desc "Check what data is stored in database for a property"
  task check_db: :environment do
    property = Property.from_rtr.where("jsonb_array_length(photos) > 0").first
    if property
      puts "Property: #{property.address}"
      puts "\n--- AMENITIES (#{property.amenities&.count || 0}) ---"
      property.amenities&.first(5)&.each { |a| puts "  #{a.inspect}" }
      puts "\n--- amenity_list helper ---"
      puts "  #{property.amenity_list.first(5).inspect}"
      puts "\n--- RATES (#{property.rates&.count || 0}) ---"
      property.rates&.first(3)&.each { |r| puts "  #{r.inspect}" }
      puts "\n--- AVAILABILITY (#{property.availability&.count || 0}) ---"
      property.availability&.first(3)&.each { |a| puts "  #{a.inspect}" }
    else
      puts "No RTR property with photos found"
    end
  end
end
