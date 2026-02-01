module ApplicationHelper
  include Pagy::Frontend

  def meta_title
    content_for?(:title) ? content_for(:title) : "Ocean City NJ Vacation Rentals | OCNJ Weekly Rentals"
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) :
      "Find your dream vacation rental in Ocean City, NJ. Browse thousands of beach properties with OCNJ Weekly Rentals by Idell Real Estate Team."
  end

  def meta_keywords
    "ocean city nj rentals, ocean city vacation rentals, jersey shore rentals, beach house rentals nj, ocean city properties"
  end

  def meta_image
    content_for?(:meta_image) ? content_for(:meta_image) : "https://ocnjweeklyrentals.com/og-image.png"
  end

  def canonical_url
    content_for?(:canonical_url) ? content_for(:canonical_url) : request.original_url.split("?").first
  end
end
