# Geocoder configuration for Azure Maps
# Ensure environment variables are loaded
require "dotenv/rails" if defined?(Dotenv)

if Rails.env.test? || ENV["CI"] == "true" || ENV["GITHUB_ACTIONS"] == "true" || ENV["GEOCODER_DISABLED"] == "true"
  # Test mode - use much faster test adapter
  puts "🌍 Using Geocoder test mode configuration" if Rails.env.development?
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
elsif ENV["AZURE_MAPS_API_KEY"].present?
  # Production/Development mode - Azure Maps
  puts "🌍 Using Azure Maps geocoding service" if Rails.env.development?

  Geocoder.configure(
    lookup: :azure,
    api_key: ENV["AZURE_MAPS_API_KEY"],
    language: :en,
    use_https: true,
    timeout: 5
  )
else
  puts "🌍 Falling back to Nominatim geocoding service" if Rails.env.development?

  Geocoder.configure(
    lookup: :nominatim,
    api_key: nil,
    language: :en,
    use_https: true,
    timeout: 5,
    http_headers: {
      "User-Agent" => ENV["NOMINATIM_USER_AGENT"]
    }
  )
end
