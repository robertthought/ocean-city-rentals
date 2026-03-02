class ContentReminderMailer < ApplicationMailer
  default from: "OCNJ Weekly Rentals <rentals@ocnjweeklyrentals.com>"

  def monthly_reminder
    @month = Date.current.strftime("%B")
    @year = Date.current.year
    @content_ideas = content_ideas_for_month(Date.current.month)
    @draft_articles = Article.draft.order(created_at: :desc).limit(5)
    @published_count = Article.published.where("published_at >= ?", 30.days.ago).count

    mail(
      to: ENV.fetch("ADMIN_EMAIL", "rentals@ocnjweeklyrentals.com"),
      subject: "📝 #{@month} Content Reminder - Ocean City Blog Ideas"
    )
  end

  private

  def content_ideas_for_month(month)
    ideas = {
      1 => [ # January
        { title: "Planning Your Ocean City Summer Vacation #{Date.current.year}", category: "Vacation Planning", keywords: "summer vacation planning, book early" },
        { title: "Off-Season Ocean City: Winter Weekend Getaway Guide", category: "Travel Tips", keywords: "winter getaway, off-season" },
        { title: "First Night Ocean City Recap & Photos", category: "Events", keywords: "new years eve, first night" }
      ],
      2 => [ # February
        { title: "Valentine's Day in Ocean City: Romantic Getaway Ideas", category: "Travel Tips", keywords: "romantic getaway, couples" },
        { title: "Early Bird Rental Deals: Book Now for Summer #{Date.current.year}", category: "Vacation Planning", keywords: "early booking, summer deals" },
        { title: "Presidents Day Weekend in Ocean City", category: "Events", keywords: "presidents day, long weekend" }
      ],
      3 => [ # March
        { title: "Spring Break in Ocean City #{Date.current.year}: What's Open", category: "Travel Tips", keywords: "spring break, march" },
        { title: "Ocean City Beach Tag Prices #{Date.current.year}: Complete Guide", category: "Beach Guide", keywords: "beach tags, beach pass prices" },
        { title: "Best Time to Book Your Summer Rental", category: "Vacation Planning", keywords: "when to book, summer rental" }
      ],
      4 => [ # April
        { title: "Doo Dah Parade #{Date.current.year}: Date, Time & Route", category: "Events", keywords: "doo dah parade, spring events" },
        { title: "Easter Weekend in Ocean City: Family Activities", category: "Events", keywords: "easter, family activities" },
        { title: "Ocean City Fishing Season Opens: What You Need to Know", category: "Activities", keywords: "fishing season, spring fishing" }
      ],
      5 => [ # May
        { title: "Memorial Day Weekend Ocean City #{Date.current.year}: Complete Guide", category: "Events", keywords: "memorial day, summer kickoff" },
        { title: "What to Pack for Your Ocean City Vacation", category: "Travel Tips", keywords: "packing list, beach vacation" },
        { title: "Ocean City Boardwalk: What's New for #{Date.current.year}", category: "Activities", keywords: "boardwalk, new attractions" }
      ],
      6 => [ # June
        { title: "Summer #{Date.current.year} Ocean City Events Calendar", category: "Events", keywords: "summer events, june calendar" },
        { title: "Best Ice Cream on the Ocean City Boardwalk", category: "Food & Dining", keywords: "ice cream, boardwalk food" },
        { title: "Ocean City Beach Safety Tips for Families", category: "Beach Guide", keywords: "beach safety, family tips" }
      ],
      7 => [ # July
        { title: "Night in Venice #{Date.current.year}: Complete Viewing Guide", category: "Events", keywords: "night in venice, boat parade" },
        { title: "4th of July Fireworks Ocean City #{Date.current.year}", category: "Events", keywords: "fireworks, fourth of july" },
        { title: "Beat the Heat: Best Air-Conditioned Activities in Ocean City", category: "Activities", keywords: "indoor activities, rainy day" }
      ],
      8 => [ # August
        { title: "Baby Parade #{Date.current.year}: Registration & Schedule", category: "Events", keywords: "baby parade, august events" },
        { title: "Last-Minute Labor Day Rentals Still Available", category: "Vacation Planning", keywords: "labor day, last minute rentals" },
        { title: "End of Summer Ocean City Bucket List", category: "Activities", keywords: "summer bucket list, things to do" }
      ],
      9 => [ # September
        { title: "Labor Day Weekend Ocean City #{Date.current.year}", category: "Events", keywords: "labor day, september" },
        { title: "Fall in Ocean City: Why September is the Best Month", category: "Travel Tips", keywords: "fall vacation, september" },
        { title: "Ocean City Block Party Schedule Fall #{Date.current.year}", category: "Events", keywords: "block party, fall events" }
      ],
      10 => [ # October
        { title: "Halloween in Ocean City: Family-Friendly Events", category: "Events", keywords: "halloween, family events" },
        { title: "Fall Fishing in Ocean City: Best Spots & Tips", category: "Activities", keywords: "fall fishing, october" },
        { title: "Off-Season Rental Deals: Save Big This Fall", category: "Vacation Planning", keywords: "off-season, fall deals" }
      ],
      11 => [ # November
        { title: "Thanksgiving in Ocean City: Where to Eat", category: "Food & Dining", keywords: "thanksgiving, restaurants" },
        { title: "Black Friday: Book Your #{Date.current.year + 1} Summer Rental", category: "Vacation Planning", keywords: "black friday, early booking" },
        { title: "Winter Walking in Ocean City: Off-Season Beach Guide", category: "Beach Guide", keywords: "winter beach, off-season" }
      ],
      12 => [ # December
        { title: "Holiday Events in Ocean City #{Date.current.year}", category: "Events", keywords: "christmas, holiday events" },
        { title: "First Night Ocean City #{Date.current.year + 1}: NYE Guide", category: "Events", keywords: "new years eve, first night" },
        { title: "#{Date.current.year + 1} Ocean City Vacation Planning Guide", category: "Vacation Planning", keywords: "next year, planning ahead" }
      ]
    }

    ideas[month] || ideas[6] # Default to June ideas
  end
end
