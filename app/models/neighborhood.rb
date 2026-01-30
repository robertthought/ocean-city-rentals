# Neighborhood is a non-database model representing Ocean City areas
# Properties are assigned to neighborhoods based on their block number (address pattern)

class Neighborhood
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :slug, :string
  attribute :name, :string
  attribute :street_range, :string
  attribute :description, :string
  attribute :highlights, default: []
  attribute :block_range # Range object for matching properties

  NEIGHBORHOODS = [
    {
      slug: "north-end",
      name: "North End",
      street_range: "1st - 9th Streets",
      block_range: 1..999,
      description: "The North End of Ocean City offers a quieter, more residential atmosphere while still being close to all the action. This family-friendly area features beautiful beaches, easy bay access, and a peaceful retreat from the busier downtown areas.",
      highlights: [
        "Quieter beaches with less crowds",
        "Close to Corson's Inlet State Park",
        "Easy access to bay for fishing and kayaking",
        "Family-friendly neighborhood feel",
        "Short drive or bike ride to boardwalk"
      ]
    },
    {
      slug: "downtown",
      name: "Downtown",
      street_range: "10th - 25th Streets",
      block_range: 1000..2599,
      description: "Downtown Ocean City is the heart of the action, home to the famous boardwalk, Music Pier, and Gillian's Wonderland Pier. This central location puts you steps away from restaurants, shops, amusements, and the best of Ocean City's entertainment.",
      highlights: [
        "Walking distance to the boardwalk",
        "Close to Gillian's Wonderland Pier",
        "Near Music Pier and events",
        "Abundant restaurants and shops",
        "Central beach access"
      ]
    },
    {
      slug: "midtown",
      name: "Midtown",
      street_range: "26th - 39th Streets",
      block_range: 2600..3999,
      description: "Midtown Ocean City offers the perfect balance between the bustling downtown and the quieter south end. Enjoy easy access to both the beach and bay, with a mix of classic shore homes and modern rentals.",
      highlights: [
        "Balance of quiet and convenience",
        "Beautiful wide beaches",
        "Good mix of dining options",
        "Easy beach and bay access",
        "Less crowded than downtown"
      ]
    },
    {
      slug: "south-end",
      name: "South End",
      street_range: "40th - 59th Streets",
      block_range: 4000..5999,
      description: "The South End of Ocean City is known for its wide, pristine beaches and relaxed atmosphere. Perfect for families seeking a peaceful beach vacation, this area offers stunning sunrises, excellent surfing, and a true escape from the everyday.",
      highlights: [
        "Widest beaches in Ocean City",
        "Popular surfing destination",
        "Peaceful, residential atmosphere",
        "Beautiful sunrise views",
        "Less crowded year-round"
      ]
    },
    {
      slug: "beachfront",
      name: "Beachfront",
      street_range: "Ocean Ave & Boardwalk",
      block_range: nil, # Special matching logic
      description: "Nothing beats waking up to ocean views. Beachfront properties along Ocean Avenue and the Boardwalk offer unparalleled access to the beach and the iconic Ocean City Boardwalk experience.",
      highlights: [
        "Direct ocean views",
        "Steps to the beach",
        "Boardwalk access",
        "Sunrise from your window",
        "Premium vacation experience"
      ]
    }
  ].freeze

  class << self
    def all
      @all ||= NEIGHBORHOODS.map { |attrs| new(attrs) }
    end

    def find(slug)
      all.find { |n| n.slug == slug } || raise(ActiveRecord::RecordNotFound, "Neighborhood not found")
    end

    def for_property(property)
      return find("beachfront") if beachfront_address?(property.address)

      block_num = extract_block_number(property.address)
      return nil unless block_num

      all.find { |n| n.block_range&.include?(block_num) }
    end

    private

    def beachfront_address?(address)
      address.match?(/\b(Ocean\s+Ave|Boardwalk)\b/i)
    end

    def extract_block_number(address)
      match = address.match(/^(\d{2,4})[\s-]/)
      match ? match[1].to_i : nil
    end
  end

  def properties
    Property.in_ocean_city.where("#{property_sql_condition}")
  end

  def property_count
    @property_count ||= properties.count
  end

  def to_param
    slug
  end

  private

  def property_sql_condition
    if slug == "beachfront"
      "address ~* '\\m(Ocean\\s+Ave|Boardwalk)\\M'"
    elsif block_range
      <<-SQL
        CAST(
          CASE
            WHEN address ~ '^[0-9]{2,4}[\\s-]'
            THEN SUBSTRING(address FROM '^([0-9]{2,4})')
            ELSE '0'
          END AS INTEGER
        ) BETWEEN #{block_range.min} AND #{block_range.max}
        AND address !~* '\\m(Ocean\\s+Ave|Boardwalk)\\M'
      SQL
    else
      "1=0"
    end
  end
end
