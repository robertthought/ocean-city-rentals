# Service for interacting with the RealTimeRental SOAP/XML API
# API Documentation: RTR_APICatalogV4_2020.01.08
#
# Endpoints:
#   - HelloWorld: Test connectivity
#   - RtrPropertyCatalog: Full property catalog
#   - RtrPropertyChangeLogCatalog: Properties changed since a date
#
class RealTimeRentalApi
  API_ENDPOINT = "https://www.realtimerental.com/WebService/rtrapi.asmx"
  NAMESPACE = "http://realtimerental.com/webservice"

  class ApiError < StandardError; end

  def initialize(api_key = nil)
    @api_key = api_key || ENV["RTR_API_KEY"]
    raise ApiError, "RTR_API_KEY is required" if @api_key.blank?
  end

  # Test API connectivity
  def hello_world
    response = make_request("HelloWorld", "")
    response.include?("Hi!") || response.include?("Test Successful")
  end

  # Fetch full property catalog (generated between midnight and 4am ET daily)
  def fetch_property_catalog
    body = <<~XML
      <web:RtrPropertyCatalog>
        <web:rtrKey>#{@api_key}</web:rtrKey>
      </web:RtrPropertyCatalog>
    XML

    response = make_request("RtrPropertyCatalog", body)
    parse_properties(response)
  end

  # Fetch properties changed since a specific date/time
  # Options bit flags:
  #   1 = PropDetails, 2 = BrokerInfo, 4 = PhotoURLs,
  #   8 = Availability, 16 = Amenities, 32 = Rates
  #   63 = All information
  def fetch_change_log(since: 1.day.ago, options: 63)
    formatted_date = since.strftime("%Y-%m-%dT%H:%M:%S")

    body = <<~XML
      <web:RtrPropertyChangeLogCatalog>
        <web:rtrKey>#{@api_key}</web:rtrKey>
        <web:options>#{options}</web:options>
        <web:changesFromDate>#{formatted_date}</web:changesFromDate>
      </web:RtrPropertyChangeLogCatalog>
    XML

    response = make_request("RtrPropertyChangeLogCatalog", body)
    parse_properties(response)
  end

  private

  def make_request(action, body)
    uri = URI(API_ENDPOINT)

    envelope = build_soap_envelope(body)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 300 # 5 minutes for large catalogs
    http.open_timeout = 30

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/soap+xml; charset=utf-8"
    request["SOAPAction"] = "#{NAMESPACE}/#{action}"
    request.body = envelope

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise ApiError, "HTTP #{response.code}: #{response.message}"
    end

    response.body
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise ApiError, "Request timeout: #{e.message}"
  rescue StandardError => e
    raise ApiError, "Request failed: #{e.message}"
  end

  def build_soap_envelope(body)
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:web="#{NAMESPACE}">
        <soap:Header/>
        <soap:Body>
          #{body}
        </soap:Body>
      </soap:Envelope>
    XML
  end

  def parse_properties(xml_response)
    doc = Nokogiri::XML(xml_response)
    doc.remove_namespaces!

    properties = []

    doc.xpath("//Property").each do |prop|
      property_data = {
        rtr_reference_id: prop.at_xpath("ReferenceID")&.text&.to_i,
        rtr_property_id: prop.at_xpath("PropertyID")&.text&.to_i,
        is_active: prop.at_xpath("IsActive")&.text == "1",

        # Broker info
        broker_name: prop.at_xpath("PropertyManager/Name")&.text,
        broker_phone: prop.at_xpath("PropertyManager/Phone1")&.text,
        broker_email: prop.at_xpath("PropertyManager/Email")&.text,
        broker_website: prop.at_xpath("PropertyManager/WebSite")&.text,

        # Property details
        property_name: prop.at_xpath("PropertyDetails/PropertyName")&.text,
        description: prop.at_xpath("PropertyDetails/Description")&.text,
        property_type: prop.at_xpath("PropertyDetails/PropertyType")&.text,
        address: prop.at_xpath("PropertyDetails/Street")&.text,
        city: prop.at_xpath("PropertyDetails/City")&.text,
        state: prop.at_xpath("PropertyDetails/State")&.text,
        zip: prop.at_xpath("PropertyDetails/Zip")&.text,
        bedrooms: prop.at_xpath("PropertyDetails/BedRooms")&.text&.to_i,
        bathrooms: prop.at_xpath("PropertyDetails/Baths")&.text&.to_i,
        occupancy_limit: prop.at_xpath("PropertyDetails/OccupancyLimit")&.text&.to_i,
        total_sleeps: prop.at_xpath("PropertyDetails/TotalSleeps")&.text&.to_i,
        smoking: prop.at_xpath("PropertyDetails/Smoking")&.text == "1",
        fee_descriptions: prop.at_xpath("PropertyDetails/FeeDescriptions")&.text,
        rate_description: prop.at_xpath("PropertyDetails/RateDescription")&.text,

        # Coordinates
        latitude: prop.at_xpath("PropertyDetails/Coordinates/@Latitude")&.value&.to_f,
        longitude: prop.at_xpath("PropertyDetails/Coordinates/@Longitude")&.value&.to_f,

        # Virtual tour
        virtual_tour_url: prop.at_xpath("PropertyDetails/VirtualTourUrl")&.text,

        # Photos
        photos: parse_photos(prop),

        # Amenities
        amenities: parse_amenities(prop)
      }

      properties << property_data
    end

    properties
  end

  def parse_photos(prop)
    photos = []
    prop.xpath(".//Photos/Image").each do |img|
      photos << {
        id: img["ID"]&.to_i,
        url: img.text,
        caption: img["Caption"]
      }
    end
    photos
  end

  def parse_amenities(prop)
    amenities = []
    prop.xpath(".//Amenities/Amenity").each do |amenity|
      amenities << {
        id: amenity["ID"]&.to_i,
        label: amenity.at_xpath("Label")&.text,
        value: amenity.at_xpath("Value")&.text,
        description: amenity.at_xpath("Description")&.text
      }
    end
    amenities
  end
end
