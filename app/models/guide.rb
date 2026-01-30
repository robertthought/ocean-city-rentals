# Guide is a non-database model for SEO content pages
# These pages target informational search queries about Ocean City

class Guide
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :slug, :string
  attribute :title, :string
  attribute :meta_description, :string
  attribute :hero_subtitle, :string
  attribute :content, :string
  attribute :sections, default: []
  attribute :related_neighborhoods, default: []

  GUIDES = [
    {
      slug: "best-beaches",
      title: "Best Beaches in Ocean City NJ",
      meta_description: "Discover the best beaches in Ocean City, New Jersey. From family-friendly shores to quiet hideaways, find your perfect beach for your Ocean City vacation.",
      hero_subtitle: "8 miles of pristine sandy beaches await",
      sections: [
        {
          title: "Why Ocean City Beaches Are Special",
          content: <<~CONTENT
            Ocean City, New Jersey boasts over 8 miles of beautiful, well-maintained beaches that have earned it the nickname "America's Greatest Family Resort." The beaches are free to access (with a seasonal beach tag required for those 12 and older), clean, and patrolled by professional lifeguards throughout the summer season.

            What sets Ocean City beaches apart is the family-friendly atmosphere. As a "dry" town, Ocean City offers a safe, relaxed environment perfect for families with children. The beaches feature clean restrooms, outdoor showers, and are ADA accessible at numerous locations.
          CONTENT
        },
        {
          title: "North End Beaches (1st - 9th Streets)",
          content: <<~CONTENT
            The North End beaches offer a quieter, more secluded experience. These beaches tend to be less crowded than the central beaches, making them ideal for families seeking a peaceful day by the shore.

            **Highlights:**
            - Less crowded than downtown beaches
            - Close to Corson's Inlet State Park for nature walks
            - Great for shell collecting
            - Excellent for families with young children
            - Easy parking on residential streets
          CONTENT
        },
        {
          title: "Downtown Beaches (10th - 25th Streets)",
          content: <<~CONTENT
            The downtown beaches are the heart of Ocean City's beach scene. Located directly adjacent to the famous boardwalk, these beaches offer the quintessential Ocean City experience with easy access to food, games, and amusements.

            **Highlights:**
            - Steps from the boardwalk
            - Lifeguards on duty all summer
            - Beach wheelchair availability
            - Close to restrooms and food vendors
            - Music Pier concerts within earshot
          CONTENT
        },
        {
          title: "South End Beaches (40th - 59th Streets)",
          content: <<~CONTENT
            The South End features the widest beaches in Ocean City and is a favorite among surfers. These beaches offer a more relaxed atmosphere and stunning sunrise views over the Atlantic.

            **Highlights:**
            - Widest beaches in Ocean City
            - Popular surfing destination
            - Less crowded year-round
            - Spectacular sunrise views
            - Great for long beach walks
          CONTENT
        },
        {
          title: "Beach Tips for Your Visit",
          content: <<~CONTENT
            **Beach Tags:** Required for those 12 and older from mid-June through Labor Day. Purchase at beach tag booths, City Hall, or online.

            **Best Times:** Early morning (before 10 AM) and late afternoon (after 4 PM) offer the best conditions with fewer crowds and softer light.

            **What to Bring:** Sunscreen, umbrella, beach chairs, plenty of water, and snacks. Beach equipment rentals are available near the boardwalk.

            **Safety:** Always swim near a lifeguard. Check the flag system for water conditions (green = safe, yellow = caution, red = dangerous).
          CONTENT
        }
      ],
      related_neighborhoods: ["north-end", "downtown", "south-end", "beachfront"]
    },
    {
      slug: "boardwalk-guide",
      title: "Ocean City Boardwalk Guide",
      meta_description: "Your complete guide to the Ocean City NJ Boardwalk. Discover rides, restaurants, shops, and attractions on America's favorite family boardwalk.",
      hero_subtitle: "2.5 miles of family fun and memories",
      sections: [
        {
          title: "About the Ocean City Boardwalk",
          content: <<~CONTENT
            The Ocean City Boardwalk stretches 2.5 miles along the beachfront, running from 23rd Street to St. James Place near 6th Street. Built in 1880 and continuously improved over the years, it's one of the most beloved boardwalks on the East Coast.

            Unlike some other shore boardwalks, Ocean City's boardwalk maintains a family-friendly atmosphere. As a dry town, you won't find bars or alcohol vendors here—instead, you'll discover classic family amusements, delicious food, and wholesome entertainment.
          CONTENT
        },
        {
          title: "Amusement Rides & Attractions",
          content: <<~CONTENT
            **Gillian's Wonderland Pier** - A classic amusement park featuring rides for all ages, from gentle kiddie rides to thrilling attractions. The iconic Giant Wheel offers stunning views of the ocean and boardwalk.

            **Playland's Castaway Cove** - More rides and games, including go-karts, mini golf, and water rides perfect for hot summer days.

            **Arcade Games** - Multiple arc게 halls line the boardwalk with classic games, modern video games, and prize-winning opportunities.
          CONTENT
        },
        {
          title: "Boardwalk Food & Treats",
          content: <<~CONTENT
            No visit to the Ocean City Boardwalk is complete without sampling the famous food:

            - **Johnson's Popcorn** - Iconic caramel popcorn since 1940
            - **Manco & Manco Pizza** - A boardwalk institution
            - **Shriver's Salt Water Taffy** - Classic Jersey Shore candy
            - **Kohr Bros. Frozen Custard** - Creamy soft-serve perfection
            - **Curley's Fries** - Crispy, seasoned boardwalk fries

            You'll also find funnel cakes, fresh lemonade, Italian water ice, and dozens of other treats.
          CONTENT
        },
        {
          title: "Music Pier & Events",
          content: <<~CONTENT
            The historic Music Pier hosts concerts, shows, and events throughout the summer. From tribute bands to family shows, there's entertainment for everyone.

            **Weekly Events:**
            - Free concerts on the beach
            - Family movie nights
            - Hermit crab races
            - Sand sculpting contests

            Check the Ocean City events calendar for current schedules.
          CONTENT
        },
        {
          title: "Boardwalk Tips",
          content: <<~CONTENT
            **Best Times to Visit:** Mornings are great for a quiet stroll. Evenings (7-10 PM) bring the most energy and activity.

            **Parking:** Street parking is available throughout downtown. Arrive early on weekends for the best spots.

            **Biking:** Bicycles are permitted on the boardwalk before noon during summer months.

            **Getting There:** Stay in the Downtown neighborhood for walking-distance access to the boardwalk.
          CONTENT
        }
      ],
      related_neighborhoods: ["downtown", "beachfront"]
    },
    {
      slug: "family-activities",
      title: "Family Activities in Ocean City NJ",
      meta_description: "Discover the best family activities in Ocean City, NJ. From beaches and boardwalk to mini golf and nature, find fun for all ages.",
      hero_subtitle: "America's Greatest Family Resort lives up to its name",
      sections: [
        {
          title: "Why Families Love Ocean City",
          content: <<~CONTENT
            Ocean City has been called "America's Greatest Family Resort" since 1901, and it continues to earn that title every summer. The town's commitment to a family-friendly, alcohol-free environment creates a safe, welcoming atmosphere for visitors of all ages.

            Whether you have toddlers or teenagers, Ocean City offers activities that bring families together and create lasting vacation memories.
          CONTENT
        },
        {
          title: "Beach Activities",
          content: <<~CONTENT
            **Swimming & Bodyboarding** - Lifeguard-protected beaches make Ocean City ideal for swimmers of all skill levels.

            **Sand Castle Building** - The wide, sandy beaches provide perfect conditions for elaborate sand creations.

            **Beach Games** - Bring a frisbee, football, or paddleball set for hours of fun.

            **Shell Collecting** - The North End beaches near Corson's Inlet are especially good for finding shells.

            **Surfing Lessons** - Several local shops offer lessons for beginners, with the South End being a popular surfing spot.
          CONTENT
        },
        {
          title: "Boardwalk Fun",
          content: <<~CONTENT
            **Amusement Rides** - Gillian's Wonderland Pier and Playland's Castaway Cove offer rides for kids of all ages.

            **Arcade Games** - Classic boardwalk arcades with games and prizes.

            **Mini Golf** - Multiple courses along the boardwalk and nearby streets.

            **Bike Rentals** - Rent surreys, bikes, and quadricycles for family rides on the boardwalk (before noon).

            **Boardwalk Chapel** - Free family-friendly entertainment and programs.
          CONTENT
        },
        {
          title: "Beyond the Beach",
          content: <<~CONTENT
            **Corson's Inlet State Park** - Nature trails, birding, and kayaking on the north end.

            **Ocean City Aquatic Center** - Water slides, pools, and splash areas at this municipal facility.

            **Pirate Voyages** - Themed boat tours that kids love, departing from the bay.

            **Bay Fishing** - Charter boats and fishing piers offer family-friendly fishing trips.

            **Movies** - The Moorlyn Theatre shows first-run movies in a classic setting.
          CONTENT
        },
        {
          title: "Rainy Day Activities",
          content: <<~CONTENT
            Don't let a rainy day ruin your vacation! Ocean City has plenty of indoor options:

            - Boardwalk arcades stay open rain or shine
            - Escape rooms and laser tag facilities
            - Ocean City Historical Museum
            - Shopping in downtown boutiques
            - Catch a movie at the Moorlyn Theatre
            - Indoor mini golf at Congo Falls
          CONTENT
        }
      ],
      related_neighborhoods: ["north-end", "downtown", "south-end"]
    },
    {
      slug: "when-to-visit",
      title: "Best Time to Visit Ocean City NJ",
      meta_description: "Plan your Ocean City NJ vacation with our seasonal guide. Learn the best times to visit for beaches, fewer crowds, events, and the best rates.",
      hero_subtitle: "Every season has something special to offer",
      sections: [
        {
          title: "Overview: Ocean City Seasons",
          content: <<~CONTENT
            Ocean City is primarily a summer destination, with peak season running from Memorial Day through Labor Day. However, each season offers unique advantages depending on what you're looking for in your vacation.

            Your ideal visit time depends on your priorities: peak beach weather, lower prices, fewer crowds, or special events.
          CONTENT
        },
        {
          title: "Peak Season (June - August)",
          content: <<~CONTENT
            **Weather:** Hot and sunny, with temperatures in the 80s-90s°F. Water temperatures reach their warmest in August (70-75°F).

            **Pros:**
            - Perfect beach weather
            - All attractions open
            - Lifeguards on duty
            - Full boardwalk experience
            - Summer events and concerts

            **Cons:**
            - Highest rental rates
            - Most crowded beaches
            - Hardest to find parking

            **Best For:** Families seeking the full Ocean City experience with kids out of school.
          CONTENT
        },
        {
          title: "Shoulder Season (May, September)",
          content: <<~CONTENT
            **Weather:** May averages 65-75°F; September stays warm at 70-80°F. Water is cooler but still swimmable in September.

            **Pros:**
            - Lower rental rates
            - Fewer crowds
            - Pleasant weather
            - Many attractions still open
            - Easier parking

            **Cons:**
            - Some attractions may have limited hours
            - Water can be cool for swimming
            - Lifeguards have reduced schedules

            **Best For:** Couples, retirees, and families with flexible schedules looking for value.
          CONTENT
        },
        {
          title: "Off Season (October - April)",
          content: <<~CONTENT
            **Weather:** Variable, ranging from mild fall days to cold winter weather. Not beach season, but can be pleasant for walks.

            **Pros:**
            - Lowest rental rates
            - Very quiet and peaceful
            - Beautiful fall foliage
            - Off-season block parties and events
            - Great for off-season getaways

            **Cons:**
            - Most boardwalk attractions closed
            - Too cold for swimming
            - Some restaurants closed
            - Limited activities

            **Best For:** Those seeking a quiet beach town retreat, romantic getaways, or budget-conscious travelers.
          CONTENT
        },
        {
          title: "Special Events Calendar",
          content: <<~CONTENT
            **Spring:**
            - Doo Dah Parade (April)
            - Spring Block Party (May)

            **Summer:**
            - Hermit Crab Races (weekly)
            - Night in Venice boat parade (July)
            - Baby Parade (August)
            - Concerts at Music Pier (all summer)

            **Fall:**
            - Fall Block Parties (September-October)
            - Haunted attractions (October)

            **Winter:**
            - First Night celebration (New Year's Eve)

            Plan your trip around these events for an extra-special experience!
          CONTENT
        }
      ],
      related_neighborhoods: []
    },
    {
      slug: "ocean-city-dining",
      title: "Ocean City NJ Restaurant Guide",
      meta_description: "Discover the best restaurants in Ocean City, NJ. From boardwalk classics to fine dining, find where to eat during your beach vacation.",
      hero_subtitle: "From fresh seafood to boardwalk treats",
      sections: [
        {
          title: "Dining in Ocean City",
          content: <<~CONTENT
            Ocean City offers a diverse dining scene that goes far beyond boardwalk fare. From fresh-caught seafood to Italian classics, you'll find restaurants to satisfy every craving and budget.

            As a dry town, Ocean City restaurants don't serve alcohol, but many are BYOB (Bring Your Own Bottle), allowing you to enjoy wine or beer with your meal.
          CONTENT
        },
        {
          title: "Boardwalk Favorites",
          content: <<~CONTENT
            No visit is complete without trying these boardwalk institutions:

            **Manco & Manco Pizza** - Thin-crust pizza that's been a boardwalk staple for generations.

            **Johnson's Popcorn** - The caramel corn is legendary and makes a great take-home gift.

            **Kohr Bros. Frozen Custard** - Creamy orange-vanilla swirl is the signature flavor.

            **Shriver's Salt Water Taffy** - Watch them make taffy through the window.

            **Browns Restaurant** - Classic diner breakfast and donut shop.
          CONTENT
        },
        {
          title: "Seafood Restaurants",
          content: <<~CONTENT
            Ocean City's proximity to the ocean means fresh seafood is always on the menu:

            - Fresh catches of the day
            - Crab cakes (a Jersey Shore specialty)
            - Lobster and shrimp dishes
            - Raw bars with oysters and clams
            - Fish tacos and seafood sandwiches

            Many restaurants source directly from local fishermen for the freshest possible dishes.
          CONTENT
        },
        {
          title: "Family Dining",
          content: <<~CONTENT
            Ocean City's family-friendly atmosphere extends to its restaurants:

            - Kid-friendly menus at most establishments
            - Casual dress code everywhere
            - Many restaurants offer outdoor seating
            - Ice cream shops on nearly every block
            - Pizza delivery to your rental

            Most restaurants are accustomed to families with children and offer high chairs and kid-friendly options.
          CONTENT
        },
        {
          title: "BYOB Tips",
          content: <<~CONTENT
            Since Ocean City is a dry town, take advantage of the BYOB policy:

            **Before You Arrive:** Purchase wine, beer, or other beverages at liquor stores in neighboring towns (Somers Point, Marmora).

            **What to Bring:** Most restaurants allow wine and beer. Some allow spirits. Call ahead to confirm.

            **Corkage Fees:** Most BYOB restaurants don't charge corkage fees—it's one of the perks of dining in Ocean City!

            **Coolers:** Keep your beverages in a cooler at your rental and bring what you need for dinner.
          CONTENT
        }
      ],
      related_neighborhoods: ["downtown", "midtown"]
    }
  ].freeze

  class << self
    def all
      @all ||= GUIDES.map { |attrs| new(attrs) }
    end

    def find(slug)
      all.find { |g| g.slug == slug } || raise(ActiveRecord::RecordNotFound, "Guide not found")
    end
  end

  def to_param
    slug
  end

  def neighborhoods
    related_neighborhoods.map { |slug| Neighborhood.find(slug) rescue nil }.compact
  end
end
