# Ocean City Rentals - Build Specification

## Project Overview
Rebuild ocnjweeklyrentals.com as a Rails 8 application for long-tail SEO domination. Import 52K+ Ocean City properties to create individual landing pages that rank for property-specific searches and capture rental leads for Bob Idell Real Estate.

## Tech Stack (RHAPT)
- **Rails 8** (latest)
- **Hotwire** (Turbo + Stimulus)
- **Alpine.js** (for lightweight interactivity)
- **PostgreSQL** (database)
- **Tailwind CSS** (styling)

## Phase 1: MVP - Property Pages + Lead Capture

### 1. Rails Setup
```bash
rails new ocean-city-rentals --database=postgresql --css=tailwind
cd ocean-city-rentals
```

**Required Gems:**
```ruby
# Gemfile additions
gem 'friendly_id' # SEO-friendly URLs
gem 'pg_search' # Property search
gem 'pagy' # Pagination
gem 'sitemap_generator' # XML sitemap for Google
```

### 2. Database Schema

**Properties Table:**
```ruby
# db/migrate/create_properties.rb
create_table :properties do |t|
  t.string :property_id # From CSV
  t.string :address, null: false
  t.string :city, null: false
  t.string :state, null: false, default: 'NJ'
  t.string :zip, null: false
  
  # Owner info
  t.string :person_type
  t.boolean :is_verified
  t.boolean :auto_verified
  t.string :first_name
  t.string :last_name
  t.string :email_1
  t.string :email_2
  t.string :email_3
  t.string :email_4
  t.string :phone_1
  t.string :phone_2
  t.string :phone_3
  t.string :phone_4
  
  # Mailing address
  t.string :mailing_address
  t.string :mailing_city
  t.string :mailing_state
  t.string :mailing_zip
  t.string :data_source
  
  # SEO
  t.string :slug, unique: true, null: false
  t.text :meta_description
  t.text :meta_keywords
  
  # Future fields (nullable for now)
  t.decimal :latitude, precision: 10, scale: 6
  t.decimal :longitude, precision: 10, scale: 6
  t.integer :bedrooms
  t.integer :bathrooms
  t.integer :year_built
  t.string :property_type
  
  t.timestamps
end

add_index :properties, :slug, unique: true
add_index :properties, :zip
add_index :properties, :city
add_index :properties, [:city, :zip]
```

**Leads Table:**
```ruby
# db/migrate/create_leads.rb
create_table :leads do |t|
  t.references :property, null: false, foreign_key: true
  
  # Lead info
  t.string :name, null: false
  t.string :email, null: false
  t.string :phone
  t.text :message
  t.string :lead_type, default: 'rental_inquiry' # rental_inquiry, property_info, etc
  
  # Metadata
  t.string :source # direct, google, referral
  t.string :ip_address
  t.string :user_agent
  t.boolean :contacted, default: false
  t.datetime :contacted_at
  
  t.timestamps
end

add_index :leads, :email
add_index :leads, :created_at
add_index :leads, :contacted
```

### 3. Models

**Property Model:**
```ruby
# app/models/property.rb
class Property < ApplicationRecord
  extend FriendlyId
  
  friendly_id :address_slug, use: :slugged
  
  has_many :leads, dependent: :destroy
  
  validates :address, presence: true
  validates :city, presence: true
  validates :zip, presence: true
  validates :slug, presence: true, uniqueness: true
  
  # Search
  include PgSearch::Model
  pg_search_scope :search_by_address,
    against: [:address, :city, :zip],
    using: {
      tsearch: { prefix: true }
    }
  
  # Scopes
  scope :verified, -> { where(is_verified: true) }
  scope :in_ocean_city, -> { where(city: 'Ocean City') }
  
  # Generate SEO-friendly slug
  def address_slug
    "#{address}-#{city}-#{state}-#{zip}".parameterize
  end
  
  # Generate meta description
  def generate_meta_description
    "#{address}, #{city}, #{state} #{zip}. Contact Bob Idell Real Estate for rental information, availability, and booking for this Ocean City property."
  end
  
  # Full display address
  def full_address
    "#{address}, #{city}, #{state} #{zip}"
  end
  
  # Check if has contact info
  def has_owner_contact?
    email_1.present? || phone_1.present?
  end
end
```

**Lead Model:**
```ruby
# app/models/lead.rb
class Lead < ApplicationRecord
  belongs_to :property
  
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :property, presence: true
  
  # Scopes
  scope :uncontacted, -> { where(contacted: false) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Mark as contacted
  def mark_contacted!
    update(contacted: true, contacted_at: Time.current)
  end
  
  # Send notification email (implement later)
  after_create :send_notification
  
  private
  
  def send_notification
    # TODO: Send email to Bob with lead details
    # LeadMailer.new_lead(self).deliver_later
  end
end
```

### 4. Data Import

**Import Rake Task:**
```ruby
# lib/tasks/import_properties.rake
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
    
    puts "\n✅ Import complete!"
    puts "   Total imported: #{count}"
    puts "   Errors: #{errors.count}"
    
    if errors.any?
      puts "\nErrors:"
      errors.first(10).each { |e| puts "  - #{e}" }
    end
  end
  
  desc "Generate sitemap"
  task generate_sitemap: :environment do
    # This will be handled by sitemap_generator gem
    puts "Generating sitemap..."
    SitemapGenerator::Sitemap.verbose = true
    SitemapGenerator::Sitemap.create
    puts "✅ Sitemap generated!"
  end
end
```

### 5. Controllers

**Properties Controller:**
```ruby
# app/controllers/properties_controller.rb
class PropertiesController < ApplicationController
  def index
    @pagy, @properties = pagy(Property.in_ocean_city.order(:address), items: 50)
    
    if params[:q].present?
      @pagy, @properties = pagy(
        Property.search_by_address(params[:q]).order(:address),
        items: 50
      )
    end
  end
  
  def show
    @property = Property.friendly.find(params[:id])
    @lead = Lead.new(property: @property)
  rescue ActiveRecord::RecordNotFound
    redirect_to properties_path, alert: "Property not found"
  end
end
```

**Leads Controller:**
```ruby
# app/controllers/leads_controller.rb
class LeadsController < ApplicationController
  def create
    @property = Property.friendly.find(params[:property_id])
    @lead = @property.leads.new(lead_params)
    @lead.ip_address = request.remote_ip
    @lead.user_agent = request.user_agent
    @lead.source = params[:source] || 'direct'
    
    if @lead.save
      respond_to do |format|
        format.html { 
          redirect_to property_path(@property), 
          notice: "Thank you! Bob Idell will contact you shortly about #{@property.address}."
        }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "lead-form",
            partial: "leads/success",
            locals: { property: @property }
          )
        }
      end
    else
      respond_to do |format|
        format.html { 
          render "properties/show", status: :unprocessable_entity 
        }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "lead-form",
            partial: "properties/lead_form",
            locals: { property: @property, lead: @lead }
          )
        }
      end
    end
  end
  
  private
  
  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :message, :lead_type)
  end
end
```

### 6. Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "properties#index"
  
  resources :properties, only: [:index, :show] do
    resources :leads, only: [:create]
  end
  
  # SEO pages
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'
  
  # Sitemap
  get '/sitemap.xml', to: redirect('https://yourdomain.com/sitemap.xml.gz')
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
```

### 7. Views

**Properties Index (app/views/properties/index.html.erb):**
```erb
<div class="container mx-auto px-4 py-8">
  <div class="max-w-7xl mx-auto">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-4xl font-bold text-gray-900 mb-4">
        Ocean City, NJ Vacation Rentals
      </h1>
      <p class="text-xl text-gray-600">
        Browse <%= Property.in_ocean_city.count.to_s.gsub(/(\d)(?=(\d{3})+$)/, '\1,') %> 
        properties available for rent in Ocean City, New Jersey.
      </p>
    </div>
    
    <!-- Search -->
    <%= form_with url: properties_path, method: :get, class: "mb-8" do |f| %>
      <div class="flex gap-4">
        <%= f.text_field :q, 
          value: params[:q],
          placeholder: "Search by address (e.g., '123 Main St' or 'Bay Avenue')",
          class: "flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" 
        %>
        <%= f.submit "Search", class: "px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-semibold" %>
      </div>
    <% end %>
    
    <!-- Results Count -->
    <% if params[:q].present? %>
      <p class="text-gray-600 mb-4">
        Found <%= @properties.count %> properties matching "<%= params[:q] %>"
      </p>
    <% end %>
    
    <!-- Property Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <% @properties.each do |property| %>
        <%= link_to property_path(property), class: "block bg-white rounded-lg shadow-md hover:shadow-xl transition-shadow p-6" do %>
          <h3 class="text-xl font-semibold text-gray-900 mb-2">
            <%= property.address %>
          </h3>
          <p class="text-gray-600 mb-4">
            <%= property.city %>, <%= property.state %> <%= property.zip %>
          </p>
          <div class="flex items-center justify-between">
            <span class="text-blue-600 font-semibold">View Details →</span>
            <% if property.is_verified %>
              <span class="text-xs bg-green-100 text-green-800 px-2 py-1 rounded">
                Verified
              </span>
            <% end %>
          </div>
        <% end %>
      <% end %>
    </div>
    
    <!-- Pagination -->
    <div class="mt-8">
      <%== pagy_nav(@pagy) if @pagy.pages > 1 %>
    </div>
  </div>
</div>
```

**Property Show (app/views/properties/show.html.erb):**
```erb
<% content_for :title, "#{@property.full_address} | Ocean City Rentals" %>
<% content_for :meta_description, @property.meta_description %>

<div class="container mx-auto px-4 py-8">
  <div class="max-w-4xl mx-auto">
    <!-- Back link -->
    <%= link_to "← Back to all properties", properties_path, class: "text-blue-600 hover:text-blue-800 mb-4 inline-block" %>
    
    <!-- Property Header -->
    <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
      <h1 class="text-4xl font-bold text-gray-900 mb-4">
        <%= @property.address %>
      </h1>
      <p class="text-xl text-gray-600 mb-6">
        <%= @property.city %>, <%= @property.state %> <%= @property.zip %>
      </p>
      
      <% if @property.is_verified %>
        <span class="inline-block bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-semibold">
          ✓ Verified Property
        </span>
      <% end %>
    </div>
    
    <!-- Property Info -->
    <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
      <h2 class="text-2xl font-bold text-gray-900 mb-4">
        Interested in Renting This Property?
      </h2>
      <p class="text-gray-600 mb-6">
        This Ocean City property is available for vacation rental. Contact Bob Idell Real Estate 
        for availability, pricing, and booking information.
      </p>
      
      <!-- Placeholder for future features -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 py-6 border-t border-b border-gray-200">
        <div class="text-center">
          <p class="text-gray-500 text-sm">Property Type</p>
          <p class="font-semibold text-gray-900">
            <%= @property.property_type || 'Contact for Details' %>
          </p>
        </div>
        <div class="text-center">
          <p class="text-gray-500 text-sm">Bedrooms</p>
          <p class="font-semibold text-gray-900">
            <%= @property.bedrooms || 'Contact for Details' %>
          </p>
        </div>
        <div class="text-center">
          <p class="text-gray-500 text-sm">Year Built</p>
          <p class="font-semibold text-gray-900">
            <%= @property.year_built || 'Contact for Details' %>
          </p>
        </div>
      </div>
    </div>
    
    <!-- Lead Form -->
    <div class="bg-white rounded-lg shadow-lg p-8" id="contact">
      <h2 class="text-2xl font-bold text-gray-900 mb-4">
        Request Information
      </h2>
      <p class="text-gray-600 mb-6">
        Fill out the form below and Bob Idell will get back to you shortly with 
        availability and rental information for <%= @property.address %>.
      </p>
      
      <div id="lead-form">
        <%= render 'properties/lead_form', property: @property, lead: @lead %>
      </div>
    </div>
    
    <!-- SEO Content -->
    <div class="mt-8 prose prose-lg max-w-none">
      <h2>About Ocean City, NJ Vacation Rentals</h2>
      <p>
        Ocean City, New Jersey is a premier vacation destination on the Jersey Shore. 
        Known for its family-friendly beaches, boardwalk attractions, and beautiful coastal properties, 
        Ocean City offers the perfect setting for your summer vacation rental.
      </p>
      <p>
        <%= @property.address %> is located in the heart of Ocean City, providing easy access 
        to beaches, restaurants, shopping, and entertainment. Whether you're looking for a 
        week-long vacation or an extended summer rental, Bob Idell Real Estate can help you 
        secure this property.
      </p>
    </div>
  </div>
</div>
```

**Lead Form Partial (app/views/properties/_lead_form.html.erb):**
```erb
<%= form_with model: [property, lead], 
              data: { turbo_frame: "lead-form" },
              class: "space-y-4" do |f| %>
  
  <% if lead.errors.any? %>
    <div class="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded">
      <ul class="list-disc list-inside">
        <% lead.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>
  
  <div>
    <%= f.label :name, "Your Name", class: "block text-sm font-medium text-gray-700 mb-2" %>
    <%= f.text_field :name, 
      required: true,
      class: "w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" 
    %>
  </div>
  
  <div>
    <%= f.label :email, "Email Address", class: "block text-sm font-medium text-gray-700 mb-2" %>
    <%= f.email_field :email, 
      required: true,
      class: "w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" 
    %>
  </div>
  
  <div>
    <%= f.label :phone, "Phone Number (Optional)", class: "block text-sm font-medium text-gray-700 mb-2" %>
    <%= f.telephone_field :phone, 
      class: "w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" 
    %>
  </div>
  
  <div>
    <%= f.label :message, "Message", class: "block text-sm font-medium text-gray-700 mb-2" %>
    <%= f.text_area :message, 
      rows: 4,
      placeholder: "Tell us about your rental needs (dates, number of guests, etc.)",
      class: "w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" 
    %>
  </div>
  
  <%= f.hidden_field :lead_type, value: 'rental_inquiry' %>
  
  <div>
    <%= f.submit "Request Information", 
      class: "w-full px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-semibold text-lg cursor-pointer transition-colors" 
    %>
  </div>
  
  <p class="text-xs text-gray-500 text-center">
    By submitting this form, you agree to be contacted by Bob Idell Real Estate regarding this property.
  </p>
<% f %>
```

**Success Partial (app/views/leads/_success.html.erb):**
```erb
<div class="bg-green-50 border-2 border-green-200 rounded-lg p-8 text-center">
  <div class="text-green-600 text-6xl mb-4">✓</div>
  <h3 class="text-2xl font-bold text-gray-900 mb-2">
    Thank You!
  </h3>
  <p class="text-gray-600 mb-4">
    Your inquiry about <%= property.address %> has been received.
  </p>
  <p class="text-gray-600">
    Bob Idell will contact you shortly with availability and rental information.
  </p>
</div>
```

### 8. SEO Configuration

**Sitemap Generator (config/sitemap.rb):**
```ruby
# config/sitemap.rb
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
```

**Meta Tags Helper (app/helpers/application_helper.rb):**
```ruby
module ApplicationHelper
  def meta_title
    content_for?(:title) ? content_for(:title) : "Ocean City, NJ Vacation Rentals | Bob Idell Real Estate"
  end
  
  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : 
      "Browse thousands of Ocean City, NJ vacation rental properties. Find your perfect beach house with Bob Idell Real Estate."
  end
  
  def meta_keywords
    "ocean city nj rentals, ocean city vacation rentals, jersey shore rentals, beach house rentals nj, ocean city properties"
  end
end
```

**Layout Head (app/views/layouts/application.html.erb):**
```erb
<!DOCTYPE html>
<html>
  <head>
    <title><%= meta_title %></title>
    <meta name="description" content="<%= meta_description %>">
    <meta name="keywords" content="<%= meta_keywords %>">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <!-- Open Graph -->
    <meta property="og:title" content="<%= meta_title %>">
    <meta property="og:description" content="<%= meta_description %>">
    <meta property="og:type" content="website">
    <meta property="og:url" content="<%= request.original_url %>">
    
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="bg-gray-50">
    <%= render "shared/header" %>
    
    <main>
      <% if notice %>
        <div class="bg-green-50 border-l-4 border-green-400 p-4 mb-4">
          <p class="text-green-700"><%= notice %></p>
        </div>
      <% end %>
      
      <% if alert %>
        <div class="bg-red-50 border-l-4 border-red-400 p-4 mb-4">
          <p class="text-red-700"><%= alert %></p>
        </div>
      <% end %>
      
      <%= yield %>
    </main>
    
    <%= render "shared/footer" %>
  </body>
</html>
```

### 9. Deployment

**Production Setup:**
1. Create Railway/Heroku app
2. Add PostgreSQL addon
3. Set environment variables
4. Deploy

**Environment Variables:**
```bash
RAILS_ENV=production
RAILS_MASTER_KEY=<your_key>
DATABASE_URL=<postgresql_url>
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

**Deploy Commands:**
```bash
# Railway
railway up

# Or Heroku
git push heroku main
heroku run rails db:migrate
heroku run rails properties:import
heroku run rails properties:generate_sitemap
```

### 10. Post-Launch Tasks

**Immediate:**
- [ ] Submit sitemap to Google Search Console
- [ ] Submit sitemap to Bing Webmaster Tools
- [ ] Set up Google Analytics
- [ ] Test lead form submissions
- [ ] Verify all 52K pages are accessible

**Week 1:**
- [ ] Monitor Google indexing progress
- [ ] Check for 404 errors
- [ ] Set up email notifications for leads
- [ ] Add Google Maps to property pages (if lat/long available)

**Future Enhancements (Phase 2+):**
- [ ] RealTimeRental API integration
- [ ] Property images (scrape or manual upload)
- [ ] Advanced search filters (bedrooms, price, etc)
- [ ] Neighborhood pages
- [ ] Blog for content marketing
- [ ] Integration with iloveocnj.com
- [ ] Restaurant cross-promotion

## Success Metrics

**SEO Goals:**
- 52K+ pages indexed by Google within 30 days
- 100+ organic visitors/day within 60 days
- 10+ leads/week within 90 days

**Lead Generation:**
- All leads captured in database
- Email notification to Bob for each lead
- 24-hour response time target

## Notes for Claude Code

- Use Rails 8 conventions throughout
- Follow RESTful routing patterns
- Keep views simple and semantic
- Use Tailwind utility classes (no custom CSS unless necessary)
- Ensure all forms work with and without JavaScript (progressive enhancement)
- Add indexes to all frequently queried columns
- Use database-level constraints where possible
- Write descriptive commit messages
- Test locally before deploying

## Data File Location
CSV file is located at: `/mnt/user-data/uploads/batch-all-08226-properties-2026-01-22.csv`

Copy this to `db/data/` directory in the Rails app before running import.
