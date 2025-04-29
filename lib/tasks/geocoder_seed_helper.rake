# Create this file at lib/tasks/geocoder_seed_helper.rb

namespace :geocoder do
  desc "Configure Geocoder for seed data"
  task prepare_for_seeds: :environment do
    if Rails.env.test? || ENV["CI"] == "true" || ENV["GITHUB_ACTIONS"] == "true" || ENV["GEOCODER_DISABLED"] == "true"
      puts "🌍 Setting up Geocoder test mode for seed data"

      # Force Geocoder into test mode
      Geocoder.configure(
        lookup: :test,
        ip_lookup: :test
      )

      # Define a list of addresses that might be in your seed data
      seed_addresses = [
        "101 Tech Blvd, Silicon Valley, USA"
        # Add more addresses from your seeds.rb file here
      ]

      # Add stubs for each address
      seed_addresses.each do |address|
        # Create deterministic but unique coordinates based on the address
        require "digest/md5"
        seed = Digest::MD5.hexdigest(address).to_i(16)
        lat = 37.0 + (seed % 10000) / 10000.0
        lng = -122.0 + (seed / 10000 % 10000) / 10000.0

        # Add the stub
        Geocoder::Lookup::Test.add_stub(
          address, [
            {
              "coordinates"  => [ lat, lng ],
              "address"      => address,
              "state"        => address.split(", ")[1],
              "country"      => "United States",
              "country_code" => "US"
            }
          ]
        )

        puts "  ✓ Added stub for '#{address}'"
      end

      # Add a fallback stub using a regex to match anything
      Geocoder::Lookup::Test.add_stub(
        /.*/, [
          {
            "coordinates"  => [ 37.7749, -122.4194 ],
            "address"      => "Default Address, Default City, US",
            "state"        => "Default State",
            "country"      => "United States",
            "country_code" => "US"
          }
        ]
      )

      puts "✅ Geocoder configured for seed data"
    end
  end
end
