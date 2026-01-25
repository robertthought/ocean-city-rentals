module ApplicationHelper
  include Pagy::Frontend

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
