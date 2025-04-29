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
