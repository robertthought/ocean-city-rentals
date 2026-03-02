namespace :content do
  desc "Send monthly content reminder email"
  task send_reminder: :environment do
    puts "Sending monthly content reminder..."
    ContentReminderMailer.monthly_reminder.deliver_now
    puts "✓ Reminder sent to #{ENV.fetch('ADMIN_EMAIL', 'rentals@ocnjweeklyrentals.com')}"
  end

  desc "Generate draft articles for the current month"
  task generate_drafts: :environment do
    month = Date.current.month
    year = Date.current.year

    ideas = content_ideas_for_month(month, year)

    created_count = 0
    ideas.each do |idea|
      # Skip if similar article already exists
      existing = Article.where("title ILIKE ?", "%#{idea[:title].split(':').first}%").exists?
      if existing
        puts "⏭️  Skipping '#{idea[:title]}' - similar article exists"
        next
      end

      article = Article.create!(
        title: idea[:title],
        content: idea[:content],
        meta_description: idea[:meta_description],
        category: idea[:category],
        tags: idea[:keywords],
        author: "Bob Idell",
        published: false
      )

      puts "✓ Created draft: #{article.title}"
      created_count += 1
    end

    puts "\n#{created_count} draft articles created. Review them at /admin/articles"
  end

  desc "Send reminder and generate drafts (monthly cron job)"
  task monthly: :environment do
    Rake::Task["content:generate_drafts"].invoke
    Rake::Task["content:send_reminder"].invoke
  end

  def content_ideas_for_month(month, year)
    ideas = {
      1 => [
        {
          title: "Planning Your Ocean City Summer Vacation #{year}",
          category: "Vacation Planning",
          keywords: "summer vacation planning, book early, ocean city summer",
          meta_description: "Start planning your #{year} Ocean City summer vacation. Tips on when to book, where to stay, and what to expect.",
          content: <<~CONTENT
            Summer in Ocean City, NJ is just around the corner, and now is the perfect time to start planning your family vacation.

            **Why Book Early?**

            The best Ocean City rentals book up fast—especially beachfront properties and homes with pools. By January, many prime summer weeks are already reserved. Here's what you need to know:

            - Peak season runs Memorial Day through Labor Day
            - July 4th week and August are the most popular
            - Booking 3-6 months ahead gives you the best selection

            **Choosing Your Perfect Rental**

            Consider these factors when selecting your Ocean City vacation rental:

            - Location: North End for quiet beaches, Downtown for boardwalk access, South End for surfing
            - Size: How many bedrooms do you need? Remember to count sleeps, not just beds
            - Amenities: Pool, beach gear, outdoor shower, parking

            **What to Budget**

            Weekly rental rates in Ocean City vary widely:

            - Budget-friendly condos: $1,500-2,500/week
            - Mid-range beach houses: $2,500-4,500/week
            - Luxury oceanfront homes: $5,000-10,000+/week

            Don't forget to factor in beach tags ($30-35 per person for the season), food, and activities.

            **Ready to Book?**

            Browse our collection of Ocean City vacation rentals and submit an inquiry today. We respond within 24 hours with availability and pricing.
          CONTENT
        }
      ],
      3 => [
        {
          title: "Ocean City Beach Tag Prices #{year}: Complete Guide",
          category: "Beach Guide",
          keywords: "beach tags, beach pass, ocean city beaches",
          meta_description: "Everything you need to know about Ocean City NJ beach tags for #{year}. Prices, where to buy, and who needs them.",
          content: <<~CONTENT
            Planning a trip to Ocean City this summer? Here's everything you need to know about beach tags for the #{year} season.

            **What Are Beach Tags?**

            Beach tags (also called beach badges) are required to access Ocean City beaches from mid-June through Labor Day. They help fund beach maintenance, lifeguards, and beach services.

            **#{year} Beach Tag Prices**

            - Seasonal Tag: $30-35 (prices typically announced in spring)
            - Weekly Tag: $15-20
            - Daily Tag: $7-10
            - Children under 12: FREE

            *Note: Prices are estimates based on previous years. Check oceancityvacation.com for official #{year} pricing.*

            **Where to Buy Beach Tags**

            - Online: Purchase in advance at the official Ocean City website
            - Beach Tag Booths: Located at major beach entrances
            - City Hall: 861 Asbury Avenue
            - Local businesses: Some stores sell tags as a convenience

            **Tips for Beach Tag Season**

            - Buy seasonal tags early for the best value if staying multiple weeks
            - Keep your tag visible—inspectors check regularly
            - Lost tags? You'll need to purchase a replacement
            - Tags are checked most strictly during peak hours (10am-4pm)

            **Staying in a Rental?**

            Some Ocean City vacation rentals include beach tags for their guests. Ask your rental provider about beach tag availability when booking.
          CONTENT
        }
      ],
      5 => [
        {
          title: "Memorial Day Weekend Ocean City #{year}: Complete Guide",
          category: "Events",
          keywords: "memorial day, summer kickoff, may ocean city",
          meta_description: "Plan your Memorial Day weekend in Ocean City NJ. Beach openings, events, and what to expect for the unofficial start of summer.",
          content: <<~CONTENT
            Memorial Day Weekend marks the unofficial start of summer in Ocean City, NJ. Here's your complete guide to making the most of the long weekend.

            **What's Open Memorial Day Weekend?**

            - Beaches: Open with lifeguards on duty
            - Boardwalk: All shops and attractions open for the season
            - Restaurants: Most are open with regular hours
            - Amusement piers: Gillian's and Playland's are ready for summer

            **Weather Expectations**

            Memorial Day weekend weather in Ocean City typically ranges from the mid-60s to low 70s. Water temperature is usually around 55-60°F—refreshing but swimmable for the brave!

            Pack layers for cool evenings on the boardwalk.

            **Events and Activities**

            - Beach activities and swimming
            - Boardwalk rides and games
            - Mini golf courses opening for the season
            - Memorial Day observances and ceremonies

            **Booking Tips**

            Memorial Day weekend is popular—book your rental early! Many families use this weekend to:

            - Preview the island for summer vacation planning
            - Enjoy a long weekend getaway
            - Open their summer rental property

            **Traffic and Parking**

            Expect heavier traffic on Friday afternoon and Monday evening. Saturday is typically the busiest beach day. Arrive early for the best parking spots near the boardwalk.
          CONTENT
        }
      ],
      7 => [
        {
          title: "Night in Venice #{year}: Complete Viewing Guide",
          category: "Events",
          keywords: "night in venice, boat parade, july events",
          meta_description: "Everything you need to know about Night in Venice #{year} in Ocean City NJ. Parade route, best viewing spots, and tips.",
          content: <<~CONTENT
            Night in Venice is Ocean City's most spectacular summer event—a dazzling boat parade through the bay featuring hundreds of decorated and illuminated vessels.

            **What is Night in Venice?**

            Dating back to 1954, Night in Venice transforms Ocean City's back bays into a floating light show. Boats of all sizes—from kayaks to yachts—parade through the channels while residents and visitors watch from bayfront properties, bridges, and public viewing areas.

            **#{year} Date and Time**

            Night in Venice is typically held the third Saturday of July. Check Ocean City's official events calendar for the exact #{year} date.

            - Parade starts at dusk (approximately 8:30 PM)
            - Lasts about 2 hours
            - Rain date is usually the following Saturday

            **Best Viewing Spots**

            - Bay-front properties (if you're renting, check the location!)
            - Public docks and bulkheads
            - 34th Street and Bay Avenue area
            - Bridges connecting Ocean City to the mainland

            **Tips for Enjoying Night in Venice**

            - Arrive early to secure a good viewing spot
            - Bring chairs, blankets, and snacks
            - Bug spray is essential near the bay
            - Stay for the fireworks finale!

            **Want Bay-Front Access?**

            Search our bay-front vacation rentals for the ultimate Night in Venice experience. Watch the parade from your rental's private dock!
          CONTENT
        }
      ],
      8 => [
        {
          title: "Baby Parade #{year}: Registration & Schedule",
          category: "Events",
          keywords: "baby parade, august events, family events",
          meta_description: "Guide to Ocean City's famous Baby Parade #{year}. Registration info, parade route, and tips for participants and spectators.",
          content: <<~CONTENT
            The Ocean City Baby Parade is one of America's oldest and most beloved children's parades. If you're visiting in August, don't miss this charming tradition!

            **About the Baby Parade**

            Since 1901, children have paraded down the Ocean City boardwalk in creative costumes and decorated strollers. It's a celebration of creativity, family, and Ocean City's commitment to being "America's Greatest Family Resort."

            **#{year} Date and Time**

            The Baby Parade is traditionally held the second Thursday of August. Check Ocean City's official events calendar for the exact #{year} date.

            - Parade typically starts at 10:00 AM
            - Route: Boardwalk from 6th Street to 12th Street

            **Categories and Prizes**

            - Best Decorated Stroller/Wagon
            - Best Costume
            - Best Theme
            - And more!

            Prizes are awarded in various age groups.

            **How to Register**

            Registration is required for participants:

            - Register online through Ocean City's recreation department
            - Registration typically opens in July
            - There's a small entry fee

            **Spectator Tips**

            - Arrive early for boardwalk seating
            - The beach side offers good views
            - Bring sun protection—August is hot!
            - Cheer for the participants—it's part of the fun!

            **Staying for the Parade?**

            Book your August vacation rental now—parade week is popular with families!
          CONTENT
        }
      ]
    }

    # Return ideas for the month, or generate generic ones
    ideas[month] || [
      {
        title: "Ocean City Vacation Tips for #{Date::MONTHNAMES[month]} #{year}",
        category: "Travel Tips",
        keywords: "ocean city, vacation tips, #{Date::MONTHNAMES[month].downcase}",
        meta_description: "Planning an Ocean City vacation in #{Date::MONTHNAMES[month]}? Here's what to expect and tips for your trip.",
        content: <<~CONTENT
          #{Date::MONTHNAMES[month]} is a great time to visit Ocean City, NJ. Here's what you need to know for planning your trip.

          **Weather in #{Date::MONTHNAMES[month]}**

          [Add typical weather information for this month]

          **What's Open?**

          [Add information about which attractions and businesses are open]

          **Things to Do**

          [Add activity suggestions for this month]

          **Booking Tips**

          [Add tips for booking rentals during this time]

          Browse our vacation rentals and start planning your Ocean City getaway!
        CONTENT
      }
    ]
  end
end
