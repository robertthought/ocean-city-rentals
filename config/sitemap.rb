SitemapGenerator::Sitemap.default_host = "https://ocnjweeklyrentals.com"
SitemapGenerator::Sitemap.compress = true
SitemapGenerator::Sitemap.create_index = true

SitemapGenerator::Sitemap.create do
  # Homepage
  add root_path, priority: 1.0, changefreq: 'daily'

  # Static pages
  add about_path, priority: 0.7, changefreq: 'monthly'
  add contact_path, priority: 0.7, changefreq: 'monthly'

  # Properties index
  add properties_path, priority: 0.9, changefreq: 'daily'

  # All property pages (batched for performance)
  Property.find_each do |property|
    add property_path(property),
      priority: 0.8,
      changefreq: 'weekly',
      lastmod: property.updated_at
  end
end
