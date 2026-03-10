namespace :indexnow do
  INDEXNOW_KEY = "2048a030cb9bd3383ffc4688ad9665e4"
  INDEXNOW_HOST = "ocnjweeklyrentals.com"

  desc "Ping IndexNow with a single URL"
  task :ping, [:url] => :environment do |t, args|
    url = args[:url]
    unless url
      puts "Usage: rake indexnow:ping[https://ocnjweeklyrentals.com/some-page]"
      exit 1
    end

    require 'net/http'
    require 'uri'

    indexnow_url = "https://api.indexnow.org/indexnow?url=#{CGI.escape(url)}&key=#{INDEXNOW_KEY}"

    uri = URI.parse(indexnow_url)
    response = Net::HTTP.get_response(uri)

    puts "IndexNow Response: #{response.code} #{response.message}"
    puts "URL submitted: #{url}"
  end

  desc "Submit all guide URLs to IndexNow"
  task guides: :environment do
    require 'net/http'
    require 'uri'
    require 'json'

    urls = Guide.all.map { |g| "https://#{INDEXNOW_HOST}/guides/#{g.slug}" }

    submit_urls(urls)
  end

  desc "Submit all important pages to IndexNow"
  task all: :environment do
    require 'net/http'
    require 'uri'
    require 'json'

    urls = [
      "https://#{INDEXNOW_HOST}/",
      "https://#{INDEXNOW_HOST}/about",
      "https://#{INDEXNOW_HOST}/contact",
      "https://#{INDEXNOW_HOST}/testimonials",
      "https://#{INDEXNOW_HOST}/properties",
      "https://#{INDEXNOW_HOST}/neighborhoods",
      "https://#{INDEXNOW_HOST}/guides",
      "https://#{INDEXNOW_HOST}/blog",
      "https://#{INDEXNOW_HOST}/privacy-policy",
      "https://#{INDEXNOW_HOST}/terms-of-service"
    ]

    # Add all guides
    Guide.all.each { |g| urls << "https://#{INDEXNOW_HOST}/guides/#{g.slug}" }

    # Add all neighborhoods
    Neighborhood.all.each { |n| urls << "https://#{INDEXNOW_HOST}/neighborhoods/#{n.slug}" }

    # Add all published articles
    Article.published.each { |a| urls << "https://#{INDEXNOW_HOST}/blog/#{a.slug}" }

    submit_urls(urls)
  end

  def submit_urls(urls)
    puts "Submitting #{urls.length} URLs to IndexNow..."

    uri = URI.parse("https://api.indexnow.org/indexnow")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = {
      host: INDEXNOW_HOST,
      key: INDEXNOW_KEY,
      keyLocation: "https://#{INDEXNOW_HOST}/#{INDEXNOW_KEY}.txt",
      urlList: urls
    }.to_json

    response = http.request(request)

    puts "IndexNow Response: #{response.code} #{response.message}"
    puts "URLs submitted: #{urls.length}"

    if response.code.to_i == 200 || response.code.to_i == 202
      puts "Success! URLs will be crawled by Bing and other IndexNow partners."
    else
      puts "Error: #{response.body}"
    end
  end
end
