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
    },
    {
      slug: "pet-friendly-guide",
      title: "Pet-Friendly Ocean City NJ Vacation Guide",
      meta_description: "Plan a pet-friendly vacation in Ocean City, NJ. Dog beaches, pet rules, pet-friendly rentals, and where to find pet supplies on the island.",
      hero_subtitle: "Bring your furry family member to the beach",
      sections: [
        {
          title: "Traveling with Pets to Ocean City",
          content: <<~CONTENT
            Ocean City welcomes well-behaved pets! While there are rules to follow, many families bring their dogs to enjoy beach vacations together. This guide covers everything you need to know about visiting Ocean City with your four-legged friend.

            **Key Things to Know:**
            - Dogs are NOT allowed on the beach or boardwalk from May 1 through September 30
            - Dogs ARE welcome on beaches and boardwalk during the off-season (October - April)
            - Many vacation rentals are pet-friendly (look for our pet-friendly filter)
            - Several restaurants have outdoor seating areas that welcome dogs
          CONTENT
        },
        {
          title: "Pet-Friendly Vacation Rentals",
          content: <<~CONTENT
            Finding a pet-friendly rental is the first step to a successful vacation with your pet:

            **Tips for Booking:**
            - Book early—pet-friendly rentals are in high demand
            - Check the pet policy carefully (size limits, breed restrictions, pet deposits)
            - Look for rentals with fenced yards or easy beach access
            - Ground-floor units are often easier for pets

            **What to Bring:**
            - Pet food and treats
            - Food and water bowls
            - Leash and collar with ID tags
            - Pet bed or crate
            - Waste bags
            - Any medications your pet needs
          CONTENT
        },
        {
          title: "Where to Walk Your Dog",
          content: <<~CONTENT
            During summer months (May 1 - September 30), dogs are not permitted on beaches or the boardwalk. Here are pet-friendly alternatives:

            **Corson's Inlet State Park** - The best option for dog owners! This natural area at the north end of Ocean City allows dogs on leashes. Enjoy nature trails, dunes, and off-season beach access.

            **Residential Streets** - The quiet residential streets throughout Ocean City are perfect for dog walks. Early morning and evening walks are most comfortable in summer heat.

            **Bay Areas** - The bay side of the island offers scenic walking paths and views.

            **Off-Season Beach Access** - From October through April, dogs are welcome on beaches and the boardwalk—a perfect time for a pet-friendly getaway!
          CONTENT
        },
        {
          title: "Pet Supplies & Services",
          content: <<~CONTENT
            **Pet Stores:**
            - PetSmart and Petco are located in nearby Somers Point and Marmora
            - Local convenience stores carry basic pet supplies

            **Veterinary Services:**
            - Ocean City has veterinary clinics for emergencies
            - Keep your regular vet's number handy

            **Pet-Friendly Dining:**
            - Several restaurants with outdoor seating welcome dogs
            - Ask before bringing your pet to outdoor dining areas
            - Always bring water for your dog
          CONTENT
        },
        {
          title: "Pet Safety Tips",
          content: <<~CONTENT
            **Heat Safety:**
            - Never leave pets in parked cars
            - Walk dogs during cooler morning and evening hours
            - Provide plenty of fresh water
            - Watch for signs of overheating

            **Beach Safety (Off-Season):**
            - Keep dogs on leash near water
            - Rinse off salt water after beach visits
            - Watch for jellyfish and sharp shells
            - Don't let dogs drink salt water

            **General Tips:**
            - Keep your pet on a leash at all times
            - Clean up after your pet immediately
            - Ensure your pet has current vaccinations
            - Bring a recent photo in case your pet gets lost
          CONTENT
        }
      ],
      related_neighborhoods: ["north-end"]
    },
    {
      slug: "ocean-city-events",
      title: "Ocean City NJ Events Calendar 2026",
      meta_description: "Complete guide to Ocean City NJ events in 2026. Night in Venice, Baby Parade, concerts, hermit crab races, and seasonal festivals.",
      hero_subtitle: "Year-round events and family entertainment",
      sections: [
        {
          title: "Annual Events Overview",
          content: <<~CONTENT
            Ocean City hosts dozens of events throughout the year, from beloved summer traditions to off-season block parties. This guide covers the major events that make Ocean City special.

            **Planning Tips:**
            - Book accommodations early for major events (Night in Venice, Baby Parade)
            - Check official schedules as dates may vary slightly each year
            - Many events are free and family-friendly
          CONTENT
        },
        {
          title: "Summer Signature Events",
          content: <<~CONTENT
            **Night in Venice (July)** - Ocean City's most spectacular event! A decorated boat parade through the bay featuring hundreds of illuminated boats. Residents and visitors line the bay to watch as boats cruise through the channels.
            - Best viewing: Bay-front properties, bridges, and public bay areas
            - Typically held the third Saturday of July
            - Free to attend

            **Baby Parade (August)** - A beloved tradition since 1901! Children parade down the boardwalk in creative costumes and decorated strollers. Categories include Best Decorated Stroller, Best Costume, and more.
            - Usually held the second Thursday of August
            - Registration required for participants
            - Spectators line the boardwalk for free viewing

            **Miss Crustacean Hermit Crab Beauty Pageant** - A quirky, family-fun event where hermit crabs "compete" for the crown.
          CONTENT
        },
        {
          title: "Weekly Summer Entertainment",
          content: <<~CONTENT
            **Free Beach Concerts** - Live music on the beach throughout summer. Bring a blanket and enjoy performances ranging from tribute bands to local artists.

            **Hermit Crab Races** - Weekly races at Gillian's Wonderland Pier. Kids can rent a hermit crab for the race or bring their own.

            **Movies on the Beach** - Free family movie nights on select evenings. Check the schedule for titles and locations.

            **Music Pier Concerts** - The historic Ocean City Music Pier hosts ticketed concerts throughout the summer featuring various musical genres.

            **Wednesday Night Fireworks** - Spectacular fireworks displays light up the sky on select Wednesday evenings during peak season.
          CONTENT
        },
        {
          title: "Spring & Fall Events",
          content: <<~CONTENT
            **Doo Dah Parade (April)** - Ocean City's quirky, anything-goes parade welcomes spring. Participants create fun, creative entries—the weirder, the better!

            **Spring Block Party (May)** - Kick off the season with live music, food vendors, and family activities in the downtown area.

            **Fall Block Parties (September-October)** - As summer winds down, Ocean City hosts weekend block parties with entertainment, food, and shopping.

            **Halloween Events (October)** - Haunted houses, costume parades, and trick-or-treating events for families.
          CONTENT
        },
        {
          title: "Holiday Events",
          content: <<~CONTENT
            **First Night Ocean City (New Year's Eve)** - Family-friendly New Year's Eve celebration with entertainment, activities, and fireworks at midnight. A dry, safe alternative to typical New Year's parties.

            **Holiday House Tours (December)** - Tour beautifully decorated homes throughout Ocean City during the holiday season.

            **Easter Events (Spring)** - Egg hunts and Easter activities for children.

            **Fourth of July** - Patriotic celebrations, beach activities, and spectacular fireworks over the ocean.
          CONTENT
        }
      ],
      related_neighborhoods: ["downtown", "beachfront"]
    },
    {
      slug: "corsons-inlet-guide",
      title: "Corson's Inlet State Park Guide",
      meta_description: "Explore Corson's Inlet State Park at the north end of Ocean City, NJ. Hiking, kayaking, birding, fishing, and natural beach access.",
      hero_subtitle: "Ocean City's natural treasure",
      sections: [
        {
          title: "About Corson's Inlet State Park",
          content: <<~CONTENT
            Located at the northern tip of Ocean City, Corson's Inlet State Park offers a natural escape from the bustling beach resort. This 341-acre park preserves one of the last undeveloped areas along New Jersey's coastline.

            **Park Highlights:**
            - Natural beach (no lifeguards)
            - Coastal dunes ecosystem
            - Excellent birding location
            - Kayaking and canoeing
            - Hiking trails
            - Fishing access
            - Dog-friendly (on leash)
          CONTENT
        },
        {
          title: "Hiking & Nature Trails",
          content: <<~CONTENT
            Several trails wind through the park's diverse ecosystems:

            **Main Trail** - A relatively flat trail through coastal shrub and dune areas. Easy walking for all fitness levels.

            **Beach Access** - Paths lead to the natural beach on the Atlantic side and calmer bay waters.

            **Dune Walk** - Observe the fragile dune ecosystem and the plants that help protect the coastline.

            **Tips:**
            - Wear sturdy shoes (trails can be sandy)
            - Bring insect repellent in summer
            - Stay on marked trails to protect vegetation
            - Bring water—there are no facilities in most areas
          CONTENT
        },
        {
          title: "Water Activities",
          content: <<~CONTENT
            **Kayaking & Canoeing** - The inlet and bay areas provide excellent paddling opportunities:
            - Launch from the bay side
            - Explore tidal marshes
            - Watch for dolphins and wildlife
            - Rental kayaks available nearby

            **Fishing** - Popular spot for shore fishing:
            - Inlet fishing for striped bass, bluefish
            - Bay fishing for flounder, weakfish
            - No fishing license required for saltwater fishing in NJ

            **Swimming** - The natural beach is available for swimming, but note:
            - No lifeguards on duty
            - Currents can be strong near the inlet
            - Best for experienced swimmers
          CONTENT
        },
        {
          title: "Wildlife & Birding",
          content: <<~CONTENT
            Corson's Inlet is a premier birding destination in South Jersey:

            **Shorebirds** - Piping plovers, sanderlings, and other shorebirds nest and feed here.

            **Waterfowl** - Ducks, herons, and egrets frequent the bay and marsh areas.

            **Raptors** - Osprey and other raptors can be spotted hunting over the inlet.

            **Best Birding Times:**
            - Early morning for most species
            - Spring and fall migration periods
            - Low tide for shorebird feeding

            **Tips:**
            - Bring binoculars
            - Stay on trails to avoid disturbing nesting areas
            - The park is part of the Atlantic Flyway
          CONTENT
        },
        {
          title: "Visiting Information",
          content: <<~CONTENT
            **Location:** North end of Ocean City, accessed via Bay Road

            **Hours:** Dawn to dusk, year-round

            **Admission:** Free

            **Parking:** Free parking available at the main lot

            **Facilities:**
            - Restrooms at the main parking area
            - No food vendors—bring your own supplies
            - Portable restrooms in some areas

            **Best Time to Visit:** Early morning or late afternoon for wildlife viewing and to avoid crowds.

            **Stay Nearby:** The North End neighborhood offers easy access to the park.
          CONTENT
        }
      ],
      related_neighborhoods: ["north-end"]
    },
    {
      slug: "surfing-guide",
      title: "Ocean City NJ Surfing Guide",
      meta_description: "Learn to surf in Ocean City, NJ. Best surf spots, lessons, equipment rentals, and tips for beginners and experienced surfers.",
      hero_subtitle: "Catch waves on the Jersey Shore",
      sections: [
        {
          title: "Surfing in Ocean City",
          content: <<~CONTENT
            Ocean City offers solid surfing conditions for beginners and intermediate surfers. While not Hawaii, the Jersey Shore produces consistent waves during the right conditions, especially during hurricane swells and fall nor'easters.

            **Quick Facts:**
            - Water temp: 65-75°F in summer, requires wetsuit spring/fall
            - Best waves: Fall season (September-November)
            - Beginner-friendly: Yes, especially the South End
            - Lessons available: Yes, from local surf shops
          CONTENT
        },
        {
          title: "Best Surf Spots",
          content: <<~CONTENT
            **South End (40th-59th Streets)** - The most popular surfing area in Ocean City:
            - Designated surfing beaches
            - Consistent waves
            - Less crowded than downtown
            - Best for beginners and intermediates

            **Designated Surfing Areas:** Ocean City designates specific beaches for surfing during summer months to separate surfers from swimmers. Check posted signs for current designations.

            **North End** - Corson's Inlet area can produce good waves but requires more experience due to currents.

            **Best Conditions:**
            - Incoming tide with offshore winds
            - Post-storm swells (safe conditions only)
            - Fall nor'easters produce the best waves
          CONTENT
        },
        {
          title: "Surf Lessons & Camps",
          content: <<~CONTENT
            Several surf schools operate in Ocean City and offer lessons for all levels:

            **What to Expect:**
            - Group lessons typically 1-2 hours
            - Equipment included (board, wetsuit if needed)
            - Beach instruction before entering water
            - Instructors help you catch waves

            **Who Should Take Lessons:**
            - Complete beginners
            - Kids and teens
            - Anyone wanting to improve technique

            **Tips:**
            - Book lessons early in summer
            - Morning sessions often have better conditions
            - Wear sunscreen and rash guard
          CONTENT
        },
        {
          title: "Equipment Rentals & Shops",
          content: <<~CONTENT
            Local surf shops rent boards and wetsuits:

            **What You Can Rent:**
            - Soft-top beginner boards
            - Fiberglass shortboards and longboards
            - Wetsuits (3/2mm for summer, thicker for fall)
            - Boogie boards

            **What to Bring:**
            - Sunscreen (reef-safe preferred)
            - Rash guard
            - Board wax (often included with rental)
            - Leash (usually attached to rental board)

            **Buying Gear:**
            Local shops sell new and used boards, wetsuits, and accessories.
          CONTENT
        },
        {
          title: "Surf Etiquette & Safety",
          content: <<~CONTENT
            **Etiquette:**
            - The surfer closest to the peak has right of way
            - Don't "drop in" on someone already riding a wave
            - Take turns and respect more experienced surfers
            - Help others if you see someone in trouble

            **Safety:**
            - Know your limits—don't surf conditions beyond your ability
            - Always wear a leash
            - Watch for rip currents
            - Stay in designated surfing areas
            - Check conditions before paddling out

            **Weather:**
            - Check surf forecasts (Surfline, Magic Seaweed)
            - Avoid surfing during lightning
            - Be aware of hurricane swell dangers
          CONTENT
        }
      ],
      related_neighborhoods: ["south-end"]
    },
    {
      slug: "fishing-guide",
      title: "Ocean City NJ Fishing Guide",
      meta_description: "Complete fishing guide for Ocean City, NJ. Charter boats, surf fishing, bay fishing, and the best spots to catch fish on the Jersey Shore.",
      hero_subtitle: "World-class fishing waters",
      sections: [
        {
          title: "Fishing in Ocean City",
          content: <<~CONTENT
            Ocean City's location between the Atlantic Ocean and the back bays makes it a premier fishing destination. Whether you prefer deep-sea charter fishing, surf casting, or relaxed bay fishing, you'll find excellent opportunities here.

            **License Information:**
            - No license required for saltwater fishing in New Jersey!
            - Free registry required for shore/pier fishing (register at NJ Fish & Wildlife)
          CONTENT
        },
        {
          title: "Charter Boat Fishing",
          content: <<~CONTENT
            **Deep Sea Fishing:** Charter boats depart from Ocean City and nearby marinas for offshore fishing:

            **Target Species:**
            - Tuna (bluefin, yellowfin)
            - Mahi-mahi (dolphin fish)
            - Marlin and shark (catch and release)
            - Sea bass and flounder
            - Bluefish and striped bass

            **What's Included:**
            - Captain and crew
            - Fishing equipment and bait
            - Fish cleaning and packaging
            - Coolers for your catch

            **Tips:**
            - Book early during peak season
            - Bring seasickness medication if prone to motion sickness
            - Half-day trips are good for beginners
            - Full-day or overnight trips reach deeper waters
          CONTENT
        },
        {
          title: "Surf Fishing",
          content: <<~CONTENT
            Surf fishing from Ocean City's beaches can be productive, especially at dawn and dusk:

            **Target Species:**
            - Striped bass (spring and fall)
            - Bluefish (summer)
            - Weakfish
            - Kingfish
            - Flounder

            **Best Spots:**
            - North End near Corson's Inlet
            - South End beaches
            - Jetties and rock structures

            **Equipment:**
            - 9-12 foot surf rod
            - Spinning reel with 15-20 lb line
            - Sand spikes to hold rods
            - Waders (optional but helpful)
            - Bait: bunker, clams, bloodworms
          CONTENT
        },
        {
          title: "Bay & Inlet Fishing",
          content: <<~CONTENT
            The back bays and inlets offer excellent fishing opportunities:

            **Popular Spots:**
            - Corson's Inlet
            - Great Egg Harbor Bay
            - Bridges and bulkheads
            - Public piers and docks

            **Target Species:**
            - Flounder (fluke)
            - Weakfish
            - Striped bass
            - Crabs

            **Methods:**
            - Bottom fishing with bait
            - Jigging
            - Crabbing with traps or lines

            **Advantages:**
            - Calmer waters
            - Accessible from shore
            - Good for families and beginners
          CONTENT
        },
        {
          title: "Crabbing",
          content: <<~CONTENT
            Blue crab fishing is a favorite family activity in Ocean City:

            **Where to Crab:**
            - Back bay areas
            - Docks and bulkheads
            - Marshy areas at low tide

            **Methods:**
            - Crab traps
            - Hand lines with chicken necks
            - Crab rings
            - Dip nets

            **Regulations:**
            - Minimum size limits apply
            - Basket limits in effect
            - Check current regulations

            **Tips:**
            - Best crabbing at incoming tide
            - Use chicken necks or bunker as bait
            - Bring a cooler with ice for your catch
            - Great activity for kids
          CONTENT
        }
      ],
      related_neighborhoods: ["north-end", "south-end"]
    },
    {
      slug: "ocean-city-vs-wildwood",
      title: "Ocean City vs Wildwood NJ: Which Beach Town Is Right for You?",
      meta_description: "Compare Ocean City NJ and Wildwood NJ vacation destinations. Beaches, boardwalks, rentals, and which is best for your family vacation.",
      hero_subtitle: "Choosing between two Jersey Shore favorites",
      sections: [
        {
          title: "Overview: Two Different Experiences",
          content: <<~CONTENT
            Ocean City and Wildwood are both beloved Jersey Shore destinations, but they offer distinctly different vacation experiences. Understanding these differences will help you choose the perfect beach town for your family.

            **Ocean City:** "America's Greatest Family Resort" - quieter, alcohol-free, classic family atmosphere

            **Wildwood:** Larger, livelier boardwalk with waterparks, more nightlife (for those 21+), wider beaches
          CONTENT
        },
        {
          title: "Beach Comparison",
          content: <<~CONTENT
            **Ocean City Beaches:**
            - 8 miles of beaches
            - Beach tags required ($30-35/season for adults)
            - Lifeguards Memorial Day through Labor Day
            - Clean, well-maintained
            - ADA accessible locations

            **Wildwood Beaches:**
            - 5 miles of beaches
            - FREE - no beach tags required
            - Very wide beaches (up to 1,000 feet at low tide)
            - May require longer walk to water
            - Free beach concerts

            **Winner:** Depends on preference—Ocean City for convenience to water, Wildwood for free access and wide beaches
          CONTENT
        },
        {
          title: "Boardwalk Comparison",
          content: <<~CONTENT
            **Ocean City Boardwalk:**
            - 2.5 miles long
            - Family-focused (dry town—no alcohol)
            - Classic amusements (Gillian's, Playland's)
            - Music Pier concerts
            - More relaxed atmosphere
            - Iconic food: Manco & Manco, Johnson's Popcorn

            **Wildwood Boardwalk:**
            - 2 miles long (38 blocks)
            - Larger, flashier amusement piers
            - Waterparks and thrill rides
            - Bars and nightlife (tram cars run until late)
            - More crowded and energetic
            - Morey's Piers (major water/amusement parks)

            **Winner:** Ocean City for families with young children; Wildwood for teens and thrill-seekers
          CONTENT
        },
        {
          title: "Vacation Rentals",
          content: <<~CONTENT
            **Ocean City Rentals:**
            - Strong weekly rental market
            - Many single-family homes
            - Higher price point on average
            - Book early for summer
            - More condos downtown

            **Wildwood Rentals:**
            - Mix of motels, hotels, and rentals
            - More budget options available
            - Unique 1950s "Doo Wop" motels
            - Easier last-minute availability
            - More hotel-style options

            **Winner:** Ocean City for house rentals; Wildwood for budget flexibility
          CONTENT
        },
        {
          title: "Which Is Right for You?",
          content: <<~CONTENT
            **Choose Ocean City If:**
            - You have young children
            - You prefer a quieter atmosphere
            - You want a dry (alcohol-free) environment
            - You're looking for a classic family vacation
            - You prefer house rentals over hotels
            - You enjoy a more relaxed pace

            **Choose Wildwood If:**
            - Your kids are older/teens who want thrills
            - You want free beaches
            - You enjoy a more energetic atmosphere
            - You want waterpark access
            - You're on a tighter budget
            - You enjoy nightlife (21+)

            **The Best of Both:** Many families visit both! They're only about 30 minutes apart by car.
          CONTENT
        }
      ],
      related_neighborhoods: []
    },
    {
      slug: "book-direct-save",
      title: "Book Direct & Save on Ocean City NJ Rentals",
      meta_description: "Save money by booking your Ocean City NJ vacation rental directly. Skip Airbnb and VRBO fees and get personalized service from local experts.",
      hero_subtitle: "Why direct booking saves you money",
      sections: [
        {
          title: "The True Cost of Online Booking Platforms",
          content: <<~CONTENT
            Popular vacation rental platforms like Airbnb and VRBO charge significant fees that many travelers don't notice until checkout:

            **Typical Platform Fees:**
            - **Service Fee:** 5-15% of the booking total
            - **Cleaning Fee:** Often inflated on platforms
            - **Processing Fee:** Additional charges for payment

            **Example:** A $3,000 weekly rental can cost $3,300-$3,450 on Airbnb/VRBO after fees.

            **Book Direct:** The same rental booked directly often costs the original $3,000—no hidden fees.
          CONTENT
        },
        {
          title: "Benefits of Booking Direct",
          content: <<~CONTENT
            **Save Money:**
            - No platform service fees (save 10-15%)
            - Often better cleaning fee rates
            - No inflated pricing to cover platform commissions

            **Better Communication:**
            - Direct contact with property managers
            - Faster response times
            - Local knowledge and recommendations
            - Personal service before, during, and after your stay

            **Flexibility:**
            - More flexibility on dates and special requests
            - Easier modifications to bookings
            - Direct negotiation on longer stays
            - Personalized packages and add-ons
          CONTENT
        },
        {
          title: "Why Choose OCNJ Weekly Rentals",
          content: <<~CONTENT
            **Local Expertise Since 2016:**
            - Bob Idell Real Estate knows Ocean City inside and out
            - We can recommend the perfect neighborhood for your family
            - Personal service—talk to a real person, not a chatbot

            **Largest Selection:**
            - 17,000+ Ocean City properties in our database
            - Verified rentals with accurate information
            - Properties from all Ocean City neighborhoods

            **24-Hour Response:**
            - Quick answers to your questions
            - Fast booking confirmations
            - Support throughout your stay

            **No Booking Fees:**
            - The price you see is the price you pay
            - Transparent pricing with no surprises
          CONTENT
        },
        {
          title: "How to Book Direct",
          content: <<~CONTENT
            **Step 1: Browse Our Properties**
            Search by neighborhood, dates, bedrooms, or amenities to find your perfect rental.

            **Step 2: Submit an Inquiry**
            Fill out our simple form with your dates and questions.

            **Step 3: Get a Response**
            We respond within 24 hours with availability and pricing.

            **Step 4: Book and Save**
            Complete your booking with no hidden platform fees.

            **Questions?** Contact us anytime—we're happy to help you find the perfect Ocean City rental.
          CONTENT
        },
        {
          title: "Frequently Asked Questions",
          content: <<~CONTENT
            **Is booking direct really cheaper?**
            Yes! You avoid the 10-15% platform fees charged by Airbnb and VRBO.

            **Is it safe to book direct?**
            Absolutely. We're a licensed New Jersey real estate company with years of experience.

            **What if I need to cancel?**
            We offer clear cancellation policies, often more flexible than platform rules.

            **How do I pay?**
            We accept major credit cards with secure payment processing.

            **Can I see the property first?**
            We provide detailed photos and can arrange video tours for serious inquiries.
          CONTENT
        }
      ],
      related_neighborhoods: []
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
