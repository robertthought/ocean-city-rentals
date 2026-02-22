require 'csv'
require 'set'

namespace :regrid do
  desc "Preview import from clean Regrid data (dry run - no changes)"
  task preview: :environment do
    file_path = File.expand_path('~/Downloads/ocean_city_regrid.csv')

    unless File.exist?(file_path)
      puts "ERROR: File not found: #{file_path}"
      puts "Run this first to extract Ocean City from the full Regrid export:"
      puts "  python3 script to extract OCEAN CITY rows"
      exit 1
    end

    puts "=" * 60
    puts "REGRID IMPORT PREVIEW (DRY RUN)"
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

      # Skip duplicate parcel numbers (data issue)
      if seen_parcels.include?(parcel_num)
        skipped_duplicates += 1
        next
      end
      seen_parcels.add(parcel_num)

      # Skip PARKING parcels (not rentable properties)
      if parcel_num.to_s.include?('PARKING')
        skipped_parking += 1
        next
      end

      # Extract unit from parcel number (format: county_block_lot_unit)
      parts = parcel_num.to_s.split('_')
      unit = nil
      if parts.length > 3
        unit_code = parts[3..-1].join('_')  # Handle multi-part units
        # Strip 'C' prefix for condo units
        unit = unit_code.sub(/^C/, '') unless unit_code.empty?
      end

      regrid_parcels << {
        parcel_num: parcel_num,
        address: address,
        unit: unit,
        block: row['block'],
        lot: row['lot'],
        owner: row['owner'],
        yearbuilt: row['yearbuilt']
      }
    end

    puts "Skipped #{skipped_parking} PARKING parcels"
    puts "Skipped #{skipped_duplicates} duplicate parcel numbers"
    puts ""

    # Generate slugs, handling duplicates by appending block-lot
    address_counts = regrid_parcels.group_by { |p| [p[:address], p[:unit]] }

    regrid_parcels.each do |p|
      key = [p[:address], p[:unit]]
      if address_counts[key].count > 1
        # Duplicate address+unit combo - append block-lot to make unique
        slug_parts = [p[:address], p[:unit], "blk #{p[:block]} lot #{p[:lot]}", 'Ocean City', 'NJ', '08226'].compact
      else
        slug_parts = [p[:address], p[:unit], 'Ocean City', 'NJ', '08226'].compact
      end
      p[:slug] = slug_parts.join(' ').parameterize
    end

    puts "📊 REGRID DATA SUMMARY"
    puts "-" * 40
    puts "Total parcels: #{regrid_parcels.count}"
    puts "Unique addresses: #{regrid_parcels.map { |p| p[:address] }.uniq.count}"
    puts "Parcels with units: #{regrid_parcels.count { |p| p[:unit].present? }}"
    puts "Unique slugs: #{regrid_parcels.map { |p| p[:slug] }.uniq.count}"
    puts ""

    # Check for duplicate slugs
    slug_counts = regrid_parcels.group_by { |p| p[:slug] }
    duplicate_slugs = slug_counts.select { |slug, parcels| parcels.count > 1 }

    if duplicate_slugs.any?
      puts "⚠️  DUPLICATE SLUGS FOUND: #{duplicate_slugs.count}"
      puts "-" * 40
      duplicate_slugs.first(5).each do |slug, parcels|
        puts "  #{slug}:"
        parcels.each do |p|
          puts "    - parcel: #{p[:parcel_num]} | unit: #{p[:unit] || 'none'}"
        end
      end
      puts ""
    else
      puts "✅ All slugs are unique!"
      puts ""
    end

    # Compare to current database
    puts "📊 CURRENT DATABASE"
    puts "-" * 40
    current_count = Property.count
    current_unique_addresses = Property.distinct.count(:address)
    rtr_count = Property.where(data_source: 'realtimerental').count
    uuid_slugs = Property.where("slug ~ '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'").count

    puts "Total properties: #{current_count}"
    puts "Unique addresses: #{current_unique_addresses}"
    puts "RTR synced (keep these!): #{rtr_count}"
    puts "Broken UUID slugs: #{uuid_slugs}"
    puts ""

    # Sample slug comparisons
    puts "📋 SAMPLE SLUG PREVIEWS"
    puts "-" * 40

    samples = regrid_parcels.select { |p| p[:unit].present? }.first(5)
    samples += regrid_parcels.select { |p| p[:unit].nil? }.first(3)

    samples.each do |p|
      addr_display = p[:unit] ? "#{p[:address]} Unit #{p[:unit]}" : p[:address]
      puts "  #{addr_display}"
      puts "    → #{p[:slug]}"
      puts ""
    end

    # Impact analysis
    puts "📈 PROJECTED IMPACT"
    puts "-" * 40
    puts "New sitemap URLs: #{regrid_parcels.map { |p| p[:slug] }.uniq.count}"
    puts "Current sitemap URLs: ~#{current_count}"
    puts "Broken slugs fixed: #{uuid_slugs}"
    puts ""

    puts "=" * 60
    puts "This was a DRY RUN - no changes were made."
    puts "To proceed with import, run: rake regrid:import"
    puts "=" * 60
  end
end
