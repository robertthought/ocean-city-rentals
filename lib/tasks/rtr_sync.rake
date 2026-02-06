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
    properties = api.fetch_change_log(since: 30.hours.ago, options: 63)

    puts "Found #{properties.count} properties"

    if properties.any?
      sample = properties.first
      puts "\nSample property:"
      puts "  Reference ID: #{sample[:rtr_reference_id]}"
      puts "  Address: #{sample[:address]}"
      puts "  City: #{sample[:city]}, #{sample[:state]} #{sample[:zip]}"
      puts "  Bedrooms: #{sample[:bedrooms]}, Baths: #{sample[:bathrooms]}"
      puts "  Photos: #{sample[:photos]&.count || 0}"
      puts "  Amenities: #{sample[:amenities]&.count || 0}"
      puts "  Broker: #{sample[:broker_name]}"

      if sample[:photos]&.any?
        puts "\n  Photo URLs:"
        sample[:photos].first(3).each do |photo|
          puts "    - #{photo[:url]}"
        end
      end
    end
  end
end
