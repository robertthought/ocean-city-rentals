namespace :properties do
  desc "Regenerate all property slugs to remove UUIDs"
  task fix_slugs: :environment do
    puts "Fixing property slugs..."

    fixed = 0
    skipped = 0
    errors = []

    Property.find_each do |property|
      old_slug = property.slug
      base_slug = property.address_slug

      # Skip if already clean (no UUID pattern)
      unless old_slug =~ /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
        skipped += 1
        next
      end

      # Find unique slug by appending number if needed
      new_slug = base_slug
      counter = 2
      while Property.where(slug: new_slug).where.not(id: property.id).exists?
        new_slug = "#{base_slug}-#{counter}"
        counter += 1
      end

      property.slug = new_slug
      if property.save(validate: false)
        puts "Fixed: #{old_slug} -> #{new_slug}"
        fixed += 1
      else
        errors << "#{property.id}: #{property.errors.full_messages.join(', ')}"
      end
    end

    puts "\n--- Summary ---"
    puts "Fixed: #{fixed}"
    puts "Skipped (already clean): #{skipped}"
    puts "Errors: #{errors.count}"
    errors.each { |e| puts "  - #{e}" } if errors.any?

    puts "\nNow regenerate the sitemap with: bundle exec rake sitemap:refresh"
  end
end
