require 'csv'

namespace :properties do
  desc "Import properties from CSV"
  task import: :environment do
    file_path = Rails.root.join('db', 'data', 'batch-all-08226-properties-2026-01-22.csv')

    puts "Starting import from #{file_path}"

    count = 0
    errors = []

    CSV.foreach(file_path, headers: true) do |row|
      begin
        property = Property.find_or_initialize_by(property_id: row['Property ID'])

        property.assign_attributes(
          address: row['Address']&.strip,
          city: row['City']&.strip || 'Ocean City',
          state: row['State']&.strip || 'NJ',
          zip: row['Zip']&.strip,
          person_type: row['Person Type'],
          is_verified: row['Is Verified'] == 'Yes',
          auto_verified: row['Auto-Verified'] == 'Yes',
          first_name: row['First Name'],
          last_name: row['Last Name'],
          email_1: row['Email 1'],
          email_2: row['Email 2'],
          email_3: row['Email 3'],
          email_4: row['Email 4'],
          phone_1: row['Phone 1'],
          phone_2: row['Phone 2'],
          phone_3: row['Phone 3'],
          phone_4: row['Phone 4'],
          mailing_address: row['Mailing Address'],
          mailing_city: row['Mailing City'],
          mailing_state: row['Mailing State'],
          mailing_zip: row['Mailing Zip'],
          data_source: row['Data Source']
        )

        # Generate meta description
        property.meta_description = property.generate_meta_description

        if property.save
          count += 1
          puts "Imported: #{property.full_address}" if count % 100 == 0
        else
          errors << "Row #{row['Property ID']}: #{property.errors.full_messages.join(', ')}"
        end

      rescue => e
        errors << "Row #{row['Property ID']}: #{e.message}"
      end
    end

    puts "\nImport complete!"
    puts "   Total imported: #{count}"
    puts "   Errors: #{errors.count}"

    if errors.any?
      puts "\nErrors:"
      errors.first(10).each { |e| puts "  - #{e}" }
    end
  end

  desc "Generate sitemap"
  task generate_sitemap: :environment do
    puts "Generating sitemap..."
    SitemapGenerator::Sitemap.verbose = true
    SitemapGenerator::Sitemap.create
    puts "Sitemap generated!"
  end
end
