# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Set up Geocoder for seed data in test environment
if Rails.env.test? || ENV['CI'] == 'true' || ENV['GITHUB_ACTIONS'] == 'true' || ENV['GEOCODER_DISABLED'] == 'true'
  puts "🌍 Setting up Geocoder test mode for seed data"

  # Get list of addresses from this seed file
  seed_file_content = File.read(__FILE__)
  address_matches = seed_file_content.scan(/"([^"]*(?:Blvd|St|Ave|Way|Road|Dr|Lane|Pkwy|Hwy)[^"]*)"/)
  seed_addresses = address_matches.flatten.uniq

  puts "Found #{seed_addresses.count} potential addresses in seed data"

  # Configure test mode
  Geocoder.configure(lookup: :test, ip_lookup: :test)

  # Add a fallback stub using a regex to match any unknown address
  Geocoder::Lookup::Test.add_stub(
    /.*/, lambda do |query|
      # Create deterministic but unique coordinates
      require 'digest/md5'
      seed = Digest::MD5.hexdigest(query).to_i(16)
      lat = 37.0 + (seed % 10000) / 10000.0
      lng = -122.0 + (seed / 10000 % 10000) / 10000.0

      [{
        'coordinates'  => [lat, lng],
        'address'      => query,
        'state'        => query.split(", ")[1] || 'Unknown State',
        'country'      => 'United States',
        'country_code' => 'US'
      }]
    end
  )


  # Add specific stubs for all the addresses we found
  seed_addresses.each do |address|
    # Create deterministic but unique coordinates based on the address
    require 'digest/md5'
    seed = Digest::MD5.hexdigest(address).to_i(16)
    lat = 37.0 + (seed % 10000) / 10000.0
    lng = -122.0 + (seed / 10000 % 10000) / 10000.0

    # Add the stub
    Geocoder::Lookup::Test.add_stub(
      address, [
        {
          'coordinates'  => [ lat, lng ],
          'address'      => address,
          'state'        => address.split(", ")[1] || 'Unknown State',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )
  end

  # Add the specific address from your error message
  Geocoder::Lookup::Test.add_stub(
    "101 Tech Blvd, Silicon Valley, USA", [
      {
        'coordinates'  => [ 37.4489, -122.1602 ], # Silicon Valley-ish coordinates
        'address'      => "101 Tech Blvd, Silicon Valley, USA",
        'state'        => "Silicon Valley",
        'country'      => 'United States',
        'country_code' => 'US'
      }
    ]
  )

  puts "✅ Geocoder configured for seed data"
end

# Clear existing data
Shipment.destroy_all
ShipmentStatus.destroy_all
Truck.destroy_all
User.destroy_all
Company.destroy_all
ShipmentActionPreference.destroy_all

# Create companies
puts "Creating companies..."
company1 = Company.create!(name: "LogiCo", address: "123 Logistics Lane, Springfield, USA")
company2 = Company.create!(name: "SnapShip", address: "840 Speedy Drive, Miami, USA")

# Create users
## Users for LogiCo
puts "Creating users..."
user1 = User.create!(
  email: "john.doe@example.com",
  password: "password123",
  first_name: "John",
  last_name: "Doe",
  drivers_license: "D1234567",
  role: 0,
  home_address: "505 Developer Way, Palo Alto, USA",
  company: company1
)

user2 = User.create!(
  email: "jane.smith@example.com",
  password: "password123",
  first_name: "Jane",
  last_name: "Smith",
  drivers_license: "S7654321",
  role: 1,
  home_address: "202 Innovation Ave, Silicon Valley, USA",
  company: company1
)

user3 = User.create!(
  email: "michael.jordan@example.com",
  password: "password123",
  first_name: "Michael",
  last_name: "Jordan",
  drivers_license: "MJ123456",
  role: 1,
  home_address: "303 Startup St, San Francisco, USA",
  company: company1
)

user4 = User.create!(
  email: "sarah.connor@example.com",
  password: "password123",
  first_name: "Sarah",
  last_name: "Connor",
  drivers_license: "SC654321",
  role: 1,
  home_address: "404 Code Lane, Mountain View, USA",
  company: company1
)

## Employees of SnapShip
user7 = User.create!(
  email: "alice.johnson@example.com",
  password: "password123",
  first_name: "Alice",
  last_name: "Johnson",
  drivers_license: "AJ987654",
  role: 0,
  home_address: "111 Tech Road, Austin, USA",
  company: company2
)

user8 = User.create!(
  email: "bob.williams@example.com",
  password: "password123",
  first_name: "Bob",
  last_name: "Williams",
  drivers_license: "BW456789",
  role: 1,
  home_address: "222 Startup Blvd, Seattle, USA",
  company: company2
)

user9 = User.create!(
  email: "charlie.martin@example.com",
  password: "password123",
  first_name: "Charlie",
  last_name: "Martin",
  drivers_license: "CM112233",
  role: 1,
  home_address: "333 Innovation Ct, Boston, USA",
  company: company2
)

user10 = User.create!(
  email: "danielle.brown@example.com",
  password: "password123",
  first_name: "Danielle",
  last_name: "Brown",
  drivers_license: "DB223344",
  role: 1,
  home_address: "444 Code Parkway, Denver, USA",
  company: company2
)


## Customers
user5 = User.create!(
  email: "peter.parker@example.com",
  password: "password123",
  first_name: "Peter",
  last_name: "Parker",
  drivers_license: "PP987654",
  role: 2,
  home_address: "101 Tech Blvd, Silicon Valley, USA",
  company: nil
)

user6 = User.create!(
  email: "clark.kent@example.com",
  password: "password123",
  first_name: "Clark",
  last_name: "Kent",
  role: 2,
  home_address: "101 Fun St, Minneapolis, USA",
  company: nil
)

# Create trucks
puts "Creating trucks..."
truck1 = Truck.create!(
  make: "Volvo",
  model: "FH16",
  year: 2022,
  mileage: 5000,
  company: company1,
  weight: 44000, # Max load in kg (44 metric tons)
  length: 13600,  # 13.6 meters
  height: 2600,   # 2.6 meters
  width: 2500,    # 2.5 meters
  vin: "1HGCM82633A004352",
  license_plate: "ABC-1234"
)

truck2 = Truck.create!(
  make: "Scania",
  model: "R500",
  year: 2021,
  mileage: 12000,
  company: company1,
  weight: 42000,  # Max load in kg (42 metric tons)
  length: 13600,  # 13.6 meters
  height: 2700,   # 2.7 meters
  width: 2500,    # 2.5 meters
  vin: "2C3KA53G76H123456",
  license_plate: "XYZ-9876"
)

truck3 = Truck.create!(
  make: "Kenworth",
  model: "T680",
  year: 2020,
  mileage: 15000,
  company: company1,
  weight: 40000,  # Max load in kg (40 metric tons)
  length: 12500,  # 12.5 meters
  height: 2500,   # 2.5 meters
  width: 2450,    # 2.45 meters
  vin: "5N1AR18B98C765432",
  license_plate: "LMN-4567"
)

truck4 = Truck.create!(
  make: "Peterbilt",
  model: "579",
  year: 2019,
  mileage: 18000,
  company: company1,
  weight: 41000,  # Max load in kg (41 metric tons)
  length: 13000,  # 13 meters
  height: 2550,   # 2.55 meters
  width: 2500,    # 2.5 meters
  vin: "JH4KA9650MC012345",
  license_plate: "QWE-8523"
)

truck5 = Truck.create!(
  make: "Freightliner",
  model: "Cascadia",
  year: 2022,
  mileage: 8000,
  company: company1,
  weight: 43000,  # Max load in kg (43 metric tons)
  length: 13600,  # 13.6 meters
  height: 2700,   # 2.7 meters
  width: 2500,    # 2.5 meters
  vin: "WDBRF61J43F234567",
  license_plate: "JKL-3698"
)

truck6 = Truck.create!(
  make: "Volvo",
  model: "VNL 760",
  year: 2023,
  mileage: 5000,
  company: company2,
  weight: 45000,  # Max load in kg (45 metric tons)
  length: 13600,  # 13.6 meters
  height: 2800,   # 2.8 meters
  width: 2550,    # 2.55 meters
  vin: "1M8GDM9A8KP042788",
  license_plate: "XYZ-1234"
)

truck7 = Truck.create!(
  make: "Kenworth",
  model: "T681",
  year: 2021,
  mileage: 12000,
  company: company2,
  weight: 39500,  # Max load in kg (39.5 metric tons)
  length: 12400,  # 12.4 meters
  height: 2500,   # 2.5 meters
  width: 2450,    # 2.45 meters
  vin: "2HSCUAPR47C537921",
  license_plate: "ABC-5678"
)

truck8 = Truck.create!(
  make: "Peterbilt",
  model: "580",
  year: 2024,
  mileage: 2000,
  company: company2,
  weight: 46000,  # Max load in kg (46 metric tons)
  length: 14000,  # 14 meters
  height: 2850,   # 2.85 meters
  width: 2550,    # 2.55 meters
  vin: "3AKJHHDR4JSJM4567",
  license_plate: "LMN-9012"
)


# Create shipment statuses
puts "Creating shipment statuses..."
ShipmentStatus.create!(name: "Pre-processing", company: company1, locked_for_customers: false, closed: false)
status1 = ShipmentStatus.create!(name: "Ready", company: company1, locked_for_customers: false, closed: false)
ShipmentStatus.create!(name: "Confirmed", company: company1, locked_for_customers: true, closed: false)
status2 = ShipmentStatus.create!(name: "In Transit", company: company1, locked_for_customers: true, closed: false)
status3 = ShipmentStatus.create!(name: "Delivered", company: company1, locked_for_customers: true, closed: true)

status4 = ShipmentStatus.create!(name: "Ready", company: company2, locked_for_customers: true, closed: false)
status5 = ShipmentStatus.create!(name: "In Transit", company: company2, locked_for_customers: true, closed: false)
status6 = ShipmentStatus.create!(name: "Delivered", company: company2, locked_for_customers: true, closed: true)

# Create shipment statuses
puts "Creating shipment action preferences..."
ShipmentActionPreference.create!(action: "claimed_by_company", company: company1, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company1, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "out_for_delivery", company: company1, shipment_status: status2)
ShipmentActionPreference.create!(action: "successfully_delivered", company: company1, shipment_status: status3)

ShipmentActionPreference.create!(action: "claimed_by_company", company: company2, shipment_status_id: status4)
ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company2, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "out_for_delivery", company: company2, shipment_status: status2)
ShipmentActionPreference.create!(action: "successfully_delivered", company: company2, shipment_status: status6)


# Create shipments
puts "Creating shipments..."
Shipment.create!(
  name: "Electronics",
  sender_name: "TechWorld",
  sender_address: "101 Tech Blvd, Silicon Valley, USA",
  receiver_name: "GadgetCo",
  receiver_address: "789 Innovation St, New York, USA",
  weight: 3.5,
  length: 60.0,
  width: 40.0,
  height: 30.0,
  truck: truck1,
  shipment_status: nil,
  user: user5,
  company: company1
)

Shipment.create!(
  name: "Furniture",
  sender_name: "FurnitureHub",
  sender_address: "456 Home Decor Ave, Chicago, USA",
  receiver_name: "DecoLuxe",
  receiver_address: "321 Style St, Boston, USA",
  weight: 50.0,
  length: 200.0,
  width: 100.0,
  height: 80.0,
  truck: truck2,
  shipment_status: status2,
  user: user5,
  company: company1
)

Shipment.create!(
  name: "Medical Supplies",
  sender_name: "HealthCo",
  sender_address: "123 Wellness St, Denver, USA",
  receiver_name: "MediCenter",
  receiver_address: "456 Care Rd, Austin, USA",
  weight: 8.0,
  length: 80.0,
  width: 60.0,
  height: 50.0,
  truck: nil,
  shipment_status: status1,
  user: user5,
  company: company1
)

Shipment.create!(
  name: "Furniture",
  sender_name: "Furniture World",
  sender_address: "789 Home Ln, Seattle, USA",
  receiver_name: "CozyLiving",
  receiver_address: "321 Comfort Blvd, Boston, USA",
  weight: 40.0,
  length: 220.0,
  width: 120.0,
  height: 90.0,
  truck: nil,
  shipment_status: nil,
  user: user5,
  company: nil
)

Shipment.create!(
  name: "Clothing",
  sender_name: "FashionHouse",
  sender_address: "100 Style Ave, Miami, USA",
  receiver_name: "Trendy Threads",
  receiver_address: "200 Chic St, Los Angeles, USA",
  weight: 3.0,
  length: 60.0,
  width: 40.0,
  height: 30.0,
  truck: nil,
  shipment_status: nil,
  user: user5,
  company: nil
)

Shipment.create!(
  name: "Electronics Accessories",
  sender_name: "GadgetMart",
  sender_address: "55 Tech St, San Francisco, USA",
  receiver_name: "ElectroWorld",
  receiver_address: "77 Digital Rd, Dallas, USA",
  weight: 3.0,
  length: 50.0,
  width: 40.0,
  height: 30.0,
  truck: nil,
  shipment_status: status1,
  user: user5,
  company: company1
)

Shipment.create!(
  name: "Books",
  sender_name: "Library Supplies",
  sender_address: "123 Read Blvd, Portland, USA",
  receiver_name: "City Library",
  receiver_address: "456 Knowledge Ave, Chicago, USA",
  weight: 10.0,
  length: 40.0,
  width: 30.0,
  height: 25.0,
  truck: nil,
  shipment_status: status1,
  user: user5,
  company: company1
)

Shipment.create!(
  name: "Sports Equipment",
  sender_name: "SportsPro",
  sender_address: "99 Game Rd, Orlando, USA",
  receiver_name: "PlayNation",
  receiver_address: "88 Fitness Blvd, Atlanta, USA",
  weight: 7.5,
  length: 80.0,
  width: 60.0,
  height: 50.0,
  truck: nil,
  shipment_status: status1,
  user: user5,
  company: company1
)

Shipment.create!(
  name: "Home Appliances",
  sender_name: "ApplianceDepot",
  sender_address: "67 Power Ln, Houston, USA",
  receiver_name: "HomeTech",
  receiver_address: "34 Comfort Rd, Philadelphia, USA",
  weight: 19.44,
  length: 90.0,
  width: 70.0,
  height: 80.0,
  truck: nil,
  shipment_status: status1,
  user: user5,
  company: company1
)

Shipment.create!(
  name: "Toys",
  sender_name: "ToyFactory",
  sender_address: "101 Fun St, Minneapolis, USA",
  receiver_name: "KidsLand",
  receiver_address: "555 Happy Blvd, Charlotte, USA",
  weight: 3.0,
  length: 60.0,
  width: 50.0,
  height: 40.0,
  truck: nil,
  shipment_status: nil,
  user: user5,
  company: nil
)

Shipment.create!(
  name: "Action Figures",
  sender_name: "ToyFactory",
  sender_address: "101 Fun St, Minneapolis, USA",
  receiver_name: "KidsLand",
  receiver_address: "555 Happy Blvd, Charlotte, USA",
  weight: 2.5,
  length: 40.0,
  width: 30.0,
  height: 20.0,
  truck: nil,
  shipment_status: nil,
  user: user6,
  company: nil
)


Shipment.create!([
  { name: "Electronics", sender_name: "ElectroCorp", sender_address: "500 Circuit Ave, San Jose, USA", receiver_name: "TechMart", receiver_address: "222 Innovation Dr, Austin, USA", weight: 3.55, length: 60.0, width: 40.0, height: 30.0, truck: nil, shipment_status: nil, user: user5, company: nil },

  { name: "Books", sender_name: "ReadMore", sender_address: "88 Library Ln, Boston, USA", receiver_name: "BookWorld", receiver_address: "777 Novel St, Seattle, USA", weight: 10.0, length: 40.0, width: 30.0, height: 25.0, truck: nil, shipment_status: nil, user: user5, company: company2 },

  { name: "Furniture", sender_name: "HomeComfort", sender_address: "99 Cozy Rd, Chicago, USA", receiver_name: "HouseStyle", receiver_address: "333 Living Way, Miami, USA", weight: 25.0, length: 200.0, width: 120.0, height: 90.0, truck: nil, shipment_status: nil, user: user5, company: company2 },

  { name: "Clothing", sender_name: "FashionHub", sender_address: "123 Trendy Ave, New York, USA", receiver_name: "WearItAll", receiver_address: "444 Runway St, Los Angeles, USA", weight: 3.0, length: 60.0, width: 40.0, height: 30.0, truck: nil, shipment_status: nil, user: user5, company: nil },

  { name: "Sports Equipment", sender_name: "AthletiCo", sender_address: "456 Fit St, Denver, USA", receiver_name: "ActiveZone", receiver_address: "888 Play Blvd, Phoenix, USA", weight: 7.0, length: 80.0, width: 60.0, height: 50.0, truck: nil, shipment_status: nil, user: user5, company: nil },

  { name: "Appliances", sender_name: "KitchenPro", sender_address: "789 Cook Ln, Houston, USA", receiver_name: "HomeNeeds", receiver_address: "666 Utility Rd, Dallas, USA", weight: 40.0, length: 90.0, width: 80.0, height: 70.0, truck: nil, shipment_status: nil, user: user5, company: nil },

  { name: "Garden Tools", sender_name: "GreenThumb", sender_address: "321 Bloom Dr, Portland, USA", receiver_name: "GrowMore", receiver_address: "111 Nature St, San Diego, USA", weight: 6.67, length: 70.0, width: 50.0, height: 40.0, truck: nil, shipment_status: nil, user: user6, company: nil },

  { name: "Medical Supplies", sender_name: "MediCare", sender_address: "654 Health St, Atlanta, USA", receiver_name: "Wellness Center", receiver_address: "999 Recovery Rd, Nashville, USA", weight: 5.2, length: 70.0, width: 50.0, height: 40.0, truck: nil, shipment_status: nil, user: user6, company: nil },

  { name: "Toys", sender_name: "ToyFactory", sender_address: "101 Fun St, Minneapolis, USA", receiver_name: "KidsLand", receiver_address: "555 Happy Blvd, Charlotte, USA", weight: 3.0, length: 60.0, width: 50.0, height: 40.0, truck: nil, shipment_status: nil, user: user5, company: nil },

  { name: "Office Supplies", sender_name: "OfficeMart", sender_address: "987 Work Ave, Philadelphia, USA", receiver_name: "BizSupply", receiver_address: "121 Productivity Blvd, Las Vegas, USA", weight: 3.14, length: 50.0, width: 40.0, height: 30.0, truck: nil, shipment_status: nil, user: user6, company: nil },

  { name: "Bicycles", sender_name: "CycleWorks", sender_address: "222 Pedal Rd, Columbus, USA", receiver_name: "RideFast", receiver_address: "333 Trail Ln, Memphis, USA", weight: 15.0, length: 150.0, width: 30.0, height: 80.0, truck: nil, shipment_status: nil, user: user6, company: company2 },

  { name: "Groceries", sender_name: "FreshFoods", sender_address: "555 Market St, Omaha, USA", receiver_name: "DailyMart", receiver_address: "444 Grocery Ln, Kansas City, USA", weight: 5.0, length: 50.0, width: 40.0, height: 30.0, truck: nil, shipment_status: nil, user: user6, company: nil },

  { name: "Pet Supplies", sender_name: "PawPalace", sender_address: "789 Bark Blvd, St. Louis, USA", receiver_name: "FurryFriends", receiver_address: "888 Woof Way, Indianapolis, USA", weight: 4.1, length: 60.0, width: 50.0, height: 40.0, truck: nil, shipment_status: nil, user: user6, company: company2 },

  { name: "Cosmetics", sender_name: "BeautyGlow", sender_address: "234 Glam Ave, Detroit, USA", receiver_name: "MakeUpMart", receiver_address: "777 Chic St, Louisville, USA", weight: 2.5, length: 50.0, width: 40.0, height: 30.0, truck: nil, shipment_status: nil, user: user6, company: company2 }
])


puts "Seeding complete!"
