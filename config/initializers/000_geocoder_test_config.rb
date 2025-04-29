# Create a new file: config/initializers/000_geocoder_test_config.rb

# This initializer runs before all others to ensure Geocoder is configured
# early, even during database setup phases

if defined?(Geocoder) && (Rails.env.test? || ENV["CI"] == "true" || ENV["GITHUB_ACTIONS"] == "true")
  puts "🌍 Configuring Geocoder test mode for CI/test environment"

  # Force Geocoder into test mode with a very short timeout
  Geocoder.configure(
    lookup: :test,
    ip_lookup: :test,
    timeout: 0.1
  )

  # Create a default stub for all geocoding requests
  Geocoder::Lookup::Test.add_stub(
    "any", [
      {
        "coordinates"  => [ 40.7128, -74.0060 ],
        "address"      => "New York, NY, USA",
        "state"        => "New York",
        "country"      => "United States",
        "country_code" => "US"
      }
    ]
  )

  # Add common address stubs for seed data
  common_addresses = [
    "101 Tech Blvd, Silicon Valley, USA",
    "123 Main St, Anytown, USA",
    "456 Park Ave, Metropolis, USA",
    "789 Broadway, New City, USA",
    "10 Innovation Way, Tech Park, USA"
  ]

  # You can add more addresses from your seeds file here

  # Add a catch-all handler for the Geocoder test adapter
  module Geocoder
    module Lookup
      class Test
        alias_method :original_search, :search

        def search(query, options = {})
          # Try the original search method first
          begin
            original_search(query, options)
          rescue ArgumentError => e
            # If not found, create a stub on-the-fly with randomized but consistent coordinates
            if e.message.include?("unknown stub request")
              # Hash the query string to get consistent but unique coordinates
              query_hash = Digest::MD5.hexdigest(query.to_s).to_i(16)
              lat = 30.0 + (query_hash % 10000) / 10000.0
              lon = -100.0 + (query_hash / 10000 % 10000) / 10000.0

              # Create a new stub for this query
              add_stub(
                query.to_s, [
                  {
                    "coordinates"  => [ lat, lon ],
                    "address"      => query.to_s,
                    "state"        => "Unknown State",
                    "country"      => "United States",
                    "country_code" => "US"
                  }
                ]
              )

              # Try again with the new stub
              original_search(query, options)
            else
              raise e
            end
          end
        end
      end
    end
  end

  # Add individual stubs for each common address
  common_addresses.each do |address|
    Geocoder::Lookup::Test.add_stub(
      address, [
        {
          "coordinates"  => [ 37.7749 + rand(-0.1..0.1), -122.4194 + rand(-0.1..0.1) ],
          "address"      => address,
          "state"        => address.split(", ")[1],
          "country"      => "United States",
          "country_code" => "US"
        }
      ]
    )
  end

  # Aggressively stub all Geocoder methods that might make network calls
  module DisableGeocoderRequests
    def http_request(*args)
      raise Timeout::Error, "Geocoder HTTP requests disabled in test environment"
    end
  end

  # Apply to all lookup classes
  Geocoder::Lookup.all_services.each do |service|
    begin
      lookup = Geocoder::Lookup.get(service)
      if lookup && lookup.respond_to?(:http_client)
        lookup.singleton_class.prepend(DisableGeocoderRequests)
      end
    rescue => e
      # Ignore errors for lookups that can't be instantiated
    end
  end
end
