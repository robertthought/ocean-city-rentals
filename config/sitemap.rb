SitemapGenerator::Sitemap.default_host = "https://ocnjweeklyrentals.com"
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.create_index = true

SitemapGenerator::Sitemap.create do
  # Homepage - highest priority
  add root_path, priority: 1.0, changefreq: 'daily'

  # Static pages
  add about_path, priority: 0.7, changefreq: 'monthly'
  add contact_path, priority: 0.7, changefreq: 'monthly'

  # Properties index - high priority, changes frequently
  add properties_path, priority: 0.9, changefreq: 'daily'

  # Neighborhoods index
  add neighborhoods_path, priority: 0.9, changefreq: 'weekly'

  # Individual neighborhood pages
  Neighborhood.all.each do |neighborhood|
    add neighborhood_path(neighborhood),
      priority: 0.85,
      changefreq: 'weekly'
  end

  # Guides index
  add guides_path, priority: 0.85, changefreq: 'weekly'

  # Individual guide pages
  Guide.all.each do |guide|
    add guide_path(guide),
      priority: 0.8,
      changefreq: 'monthly'
  end

  # All property pages with images for rich results
  Property.find_each do |property|
    images = []

    # Add property photos to sitemap for image SEO
    if property.has_photos?
      property.photo_urls.first(5).each_with_index do |url, index|
        images << {
          loc: url,
          title: "#{property.address} - Ocean City NJ Vacation Rental",
          caption: "#{property.address}, #{property.city}, #{property.state} - Photo #{index + 1}"
        }
      end
    end

    add property_path(property),
      priority: 0.8,
      changefreq: 'weekly',
      lastmod: property.updated_at,
      images: images
  end
end
