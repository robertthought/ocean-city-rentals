module ApplicationHelper
  include Pagy::Frontend

  def render_markdown(text)
    return "" if text.blank?

    html = text.dup

    # Headers (## and ###)
    html.gsub!(/^### (.+)$/, '<h3 class="text-xl font-bold text-gray-900 mt-6 mb-3">\1</h3>')
    html.gsub!(/^## (.+)$/, '<h2 class="text-2xl font-bold text-gray-900 mt-8 mb-4">\1</h2>')

    # Bold
    html.gsub!(/\*\*(.+?)\*\*/, '<strong>\1</strong>')

    # Italic
    html.gsub!(/\*(.+?)\*/, '<em>\1</em>')

    # Links [text](url)
    html.gsub!(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\2" class="text-blue-600 hover:underline">\1</a>')

    # Unordered lists
    html.gsub!(/^- (.+)$/, '<li class="ml-4">\1</li>')
    html.gsub!(/(<li.*<\/li>\n?)+/) { |match| "<ul class=\"list-disc list-inside space-y-1 my-4\">#{match}</ul>" }

    # Paragraphs (double newlines)
    html = html.split(/\n\n+/).map do |para|
      para = para.strip
      if para.start_with?('<h2', '<h3', '<ul', '<ol')
        para
      else
        "<p class=\"mb-4\">#{para.gsub(/\n/, ' ')}</p>"
      end
    end.join("\n")

    html.html_safe
  end

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
