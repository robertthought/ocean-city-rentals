require 'csv'
require 'set'

namespace :regrid do
  desc "Import clean Regrid data with proper slugs"
  task import: :environment do
    # Check multiple locations for the CSV
    possible_paths = [
      Rails.root.join('tmp', 'ocean_city_regrid.csv'),
      File.expand_path('~/Downloads/ocean_city_regrid.csv'),
      File.expand_path('~/ocean_city_regrid.csv')
    ]

    file_path = possible_paths.find { |p| File.exist?(p) }

    unless file_path
      puts "ERROR: ocean_city_regrid.csv not found in:"
      possible_paths.each { |p| puts "  - #{p}" }
      exit 1
    end

    puts "Using: #{file_path}"

    puts "=" * 60
    puts "REGRID IMPORT"
    puts "=" * 60
    puts ""

    # Parse Regrid data
    seen_parcels = Set.new
    regrid_parcels = []
    skipped_parking = 0
    skipped_duplicates = 0

    CSV.foreach(file_path, headers: true) do |row|
      parcel_num = row['parcelnumb']
      address = row['address']&.strip

      # Skip duplicate parcel numbers
      if seen_parcels.include?(parcel_num)
        skipped_duplicates += 1
        next
      end
      seen_parcels.add(parcel_num)

      # Skip PARKING parcels
      if parcel_num.to_s.include?('PARKING')
        skipped_parking += 1
        next
      end

      # Extract unit from parcel number (format: county_block_lot_unit)
      parts = parcel_num.to_s.split('_')
      unit = nil
      if parts.length > 3
        unit_code = parts[3..-1].join('_')
        unit = unit_code.sub(/^C/, '') unless unit_code.empty?
      end

      regrid_parcels << {
        parcel_num: parcel_num,
        address: address,
        unit: unit,
        block: row['block'],
        lot: row['lot'],
        owner: row['owner'],
        yearbuilt: row['yearbuilt'],
        raw: row
      }
    end

    puts "Parsed #{regrid_parcels.count} parcels"
    puts "Skipped #{skipped_parking} PARKING parcels"
    puts "Skipped #{skipped_duplicates} duplicate parcel numbers"
    puts ""

    # Generate slugs, handling duplicates by appending block-lot
    address_counts = regrid_parcels.group_by { |p| [p[:address], p[:unit]] }

    regrid_parcels.each do |p|
      key = [p[:address], p[:unit]]
      if address_counts[key].count > 1
        slug_parts = [p[:address], p[:unit], "blk #{p[:block]} lot #{p[:lot]}", 'Ocean City', 'NJ', '08226'].compact
      else
        slug_parts = [p[:address], p[:unit], 'Ocean City', 'NJ', '08226'].compact
      end
      p[:slug] = slug_parts.join(' ').parameterize
    end

    # Verify all slugs unique
    slugs = regrid_parcels.map { |p| p[:slug] }
    if slugs.uniq.count != slugs.count
      puts "ERROR: Duplicate slugs detected!"
      exit 1
    end
    puts "✅ All #{slugs.count} slugs are unique"
    puts ""

    # Clear existing data (including dependent records)
    puts "Clearing existing data..."
    old_count = Property.count
    leads_count = Lead.count

    puts "  Deleting #{leads_count} leads..."
    Lead.delete_all

    # Delete other dependent tables if they exist
    %w[ownership_claims property_events property_analytics].each do |table|
      if ActiveRecord::Base.connection.table_exists?(table)
        count = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{table}").first['count']
        ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
        puts "  Deleted #{count} #{table}"
      end
    end

    puts "  Deleting #{old_count} properties..."
    Property.delete_all
    puts "Cleared all existing data"
    puts ""

    # Import new properties
    puts "Importing #{regrid_parcels.count} properties..."
    imported = 0
    errors = []

    regrid_parcels.each_with_index do |p, idx|
      raw = p[:raw]

      # Build display address with unit
      display_address = p[:unit] ? "#{p[:address]} #{p[:unit]}" : p[:address]

      property = Property.new(
        property_id: p[:parcel_num],
        address: display_address.titleize,
        city: 'Ocean City',
        state: 'NJ',
        zip: '08226',
        slug: p[:slug],
        data_source: 'Regrid',

        # Parcel data
        year_built: raw['yearbuilt'].presence&.to_i,
        latitude: raw['lat'].presence&.to_f,
        longitude: raw['lon'].presence&.to_f,

        # Owner info (for internal use)
        first_name: raw['ownfrst'],
        last_name: raw['ownlast'],
        mailing_address: raw['mailadd'],
        mailing_city: raw['mail_city'],
        mailing_state: raw['mail_state2'],
        mailing_zip: raw['mail_zip'],

        # Defaults
        owner_rental_type: 'weekly',
        owner_minimum_nights: 7
      )

      # Generate meta description
      property.meta_description = property.generate_meta_description

      if property.save
        imported += 1
        print "." if imported % 500 == 0
      else
        errors << "#{p[:parcel_num]}: #{property.errors.full_messages.join(', ')}"
      end
    end

    puts ""
    puts ""
    puts "=" * 60
    puts "IMPORT COMPLETE"
    puts "=" * 60
    puts ""
    puts "Imported: #{imported}"
    puts "Errors: #{errors.count}"

    if errors.any?
      puts ""
      puts "First 10 errors:"
      errors.first(10).each { |e| puts "  - #{e}" }
    end

    puts ""
    puts "Next steps:"
    puts "  1. Verify locally: rails server, browse properties"
    puts "  2. Generate sitemap: bundle exec rake sitemap:refresh"
    puts "  3. Check sitemap: cat public/sitemap.xml | head -50"
    puts ""
  end
end
