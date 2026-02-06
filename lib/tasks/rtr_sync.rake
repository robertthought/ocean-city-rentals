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
end
