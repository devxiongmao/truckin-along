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
  address_matches = seed_file_content.scan(/"([^"]*(?:Blvd|St|Ave|Way|Road|Rd|Dr|Lane|Ln|Pkwy|Hwy)[^"]*)"/)
  seed_addresses = address_matches.flatten.uniq

  puts "Found #{seed_addresses.count} potential addresses in seed data"

  # Configure test mode only if not already configured for production
  unless Rails.env.production? || ENV["AZURE_MAPS_API_KEY"].present?
    puts "Configuring Geocoder for seed data in test mode"
    Geocoder.configure(lookup: :test, ip_lookup: :test)
  else
    puts "Using existing Geocoder configuration for seed data"
  end

  # Add a fallback stub using a regex to match any unknown address
  Geocoder::Lookup::Test.add_stub(
    /.*/, lambda do |query|
      # Create deterministic but unique coordinates
      require 'digest/md5'
      seed = Digest::MD5.hexdigest(query).to_i(16)
      lat = 37.0 + (seed % 10000) / 10000.0
      lng = -122.0 + (seed / 10000 % 10000) / 10000.0

      [ {
        'coordinates'  => [ lat, lng ],
        'address'      => query,
        'state'        => query.split(", ")[1] || 'Unknown State',
        'country'      => 'United States',
        'country_code' => 'US'
      } ]
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

  puts "✅ Geocoder configured for seed data"
end

# Clear existing data
Rating.destroy_all
DeliveryShipment.destroy_all
Delivery.destroy_all
Offer.destroy_all
Shipment.destroy_all
ShipmentStatus.destroy_all
Truck.destroy_all
User.destroy_all
Company.destroy_all
ShipmentActionPreference.destroy_all
Form.destroy_all

# Create companies
puts "Creating companies..."
company1 = Company.create!(
  name: "LogiCo Express",
  address: "123 Logistics Lane, Springfield, USA",
  phone_number: "+1-555-123-4567"
)
company2 = Company.create!(
  name: "SnapShip Solutions",
  address: "840 Speedy Drive, Miami, USA",
  phone_number: "+1-555-987-6543"
)
company3 = Company.create!(
  name: "FastTrack Freight",
  address: "456 Transport Blvd, Dallas, USA",
  phone_number: "+1-555-456-7890"
)
company4 = Company.create!(
  name: "Reliable Routes",
  address: "789 Cargo Way, Seattle, USA",
  phone_number: "+1-555-321-0987"
)

# Create users
puts "Creating users..."

## LogiCo Express employees
user1 = User.create!(
  email: "john.doe@logico.ca",
  password: "password123",
  first_name: "John",
  last_name: "Doe",
  drivers_license: "D1234567",
  role: 0, # admin
  home_address: "505 Developer Way, Palo Alto, USA",
  company: company1
)

user2 = User.create!(
  email: "jane.smith@logico.com",
  password: "password123",
  first_name: "Jane",
  last_name: "Smith",
  drivers_license: "S7654321",
  role: 1, # driver
  home_address: "202 Innovation Ave, Silicon Valley, USA",
  company: company1
)

user3 = User.create!(
  email: "michael.jordan@logico.com",
  password: "password123",
  first_name: "Michael",
  last_name: "Jordan",
  drivers_license: "MJ123456",
  role: 1, # driver
  home_address: "303 Startup St, San Francisco, USA",
  company: company1
)

## SnapShip Solutions employees
user4 = User.create!(
  email: "alice.johnson@snapship.com",
  password: "password123",
  first_name: "Alice",
  last_name: "Johnson",
  drivers_license: "AJ987654",
  role: 0, # admin
  home_address: "111 Tech Road, Austin, USA",
  company: company2
)

user5 = User.create!(
  email: "bob.williams@snapship.com",
  password: "password123",
  first_name: "Bob",
  last_name: "Williams",
  drivers_license: "BW456789",
  role: 1, # driver
  home_address: "222 Startup Blvd, Seattle, USA",
  company: company2
)

## FastTrack Freight employees
user6 = User.create!(
  email: "charlie.martin@fasttrack.com",
  password: "password123",
  first_name: "Charlie",
  last_name: "Martin",
  drivers_license: "CM112233",
  role: 0, # admin
  home_address: "333 Innovation Ct, Boston, USA",
  company: company3
)

user7 = User.create!(
  email: "danielle.brown@fasttrack.com",
  password: "password123",
  first_name: "Danielle",
  last_name: "Brown",
  drivers_license: "DB223344",
  role: 1, # driver
  home_address: "444 Code Parkway, Denver, USA",
  company: company3
)

## Reliable Routes employees
user8 = User.create!(
  email: "emma.wilson@reliableroutes.com",
  password: "password123",
  first_name: "Emma",
  last_name: "Wilson",
  drivers_license: "EW334455",
  role: 0, # admin
  home_address: "555 Delivery Dr, Portland, USA",
  company: company4
)

user9 = User.create!(
  email: "frank.garcia@reliableroutes.com",
  password: "password123",
  first_name: "Frank",
  last_name: "Garcia",
  drivers_license: "FG445566",
  role: 1, # driver
  home_address: "666 Transport Tr, Phoenix, USA",
  company: company4
)

## Customers
user10 = User.create!(
  email: "peter.parker@example.com",
  password: "password123",
  first_name: "Peter",
  last_name: "Parker",
  drivers_license: "PP987654",
  role: 2, # customer
  home_address: "101 Tech Blvd, Silicon Valley, USA",
  company: nil
)

user11 = User.create!(
  email: "clark.kent@example.com",
  password: "password123",
  first_name: "Clark",
  last_name: "Kent",
  role: 2, # customer
  home_address: "101 Fun St, Minneapolis, USA",
  company: nil
)

user12 = User.create!(
  email: "diana.prince@example.com",
  password: "password123",
  first_name: "Diana",
  last_name: "Prince",
  role: 2, # customer
  home_address: "202 Amazon Ave, Washington DC, USA",
  company: nil
)

# Create trucks (mix of active and inactive)
puts "Creating trucks..."

## LogiCo Express trucks
truck1 = Truck.create!(
  make: "Volvo",
  model: "FH16",
  year: 2022,
  mileage: 5000,
  company: company1,
  weight: 44000,
  length: 13600,
  height: 2600,
  width: 2500,
  vin: "1HGCM82633A004352",
  license_plate: "ABC-1234",
  active: true
)

truck2 = Truck.create!(
  make: "Scania",
  model: "R500",
  year: 2021,
  mileage: 12000,
  company: company1,
  weight: 42000,
  length: 13600,
  height: 2700,
  width: 2500,
  vin: "2C3KA53G76H123456",
  license_plate: "XYZ-9876",
  active: true
)

truck3 = Truck.create!(
  make: "Kenworth",
  model: "T680",
  year: 2020,
  mileage: 15000,
  company: company1,
  weight: 40000,
  length: 12500,
  height: 2500,
  width: 2450,
  vin: "5N1AR18B98C765432",
  license_plate: "LMN-4567",
  active: false # Inactive for maintenance
)

## SnapShip Solutions trucks
truck4 = Truck.create!(
  make: "Peterbilt",
  model: "579",
  year: 2019,
  mileage: 18000,
  company: company2,
  weight: 41000,
  length: 13000,
  height: 2550,
  width: 2500,
  vin: "JH4KA9650MC012345",
  license_plate: "QWE-8523",
  active: true
)

truck5 = Truck.create!(
  make: "Freightliner",
  model: "Cascadia",
  year: 2022,
  mileage: 8000,
  company: company2,
  weight: 43000,
  length: 13600,
  height: 2700,
  width: 2500,
  vin: "WDBRF61J43F234567",
  license_plate: "JKL-3698",
  active: true
)

## FastTrack Freight trucks
truck6 = Truck.create!(
  make: "Volvo",
  model: "VNL 760",
  year: 2023,
  mileage: 5000,
  company: company3,
  weight: 45000,
  length: 13600,
  height: 2800,
  width: 2550,
  vin: "1M8GDM9A8KP042788",
  license_plate: "XYZ-1234",
  active: true
)

truck7 = Truck.create!(
  make: "Kenworth",
  model: "T681",
  year: 2021,
  mileage: 12000,
  company: company3,
  weight: 39500,
  length: 12400,
  height: 2500,
  width: 2450,
  vin: "2HSCUAPR47C537921",
  license_plate: "ABC-5678",
  active: false # Inactive for maintenance
)

## Reliable Routes trucks
truck8 = Truck.create!(
  make: "Peterbilt",
  model: "580",
  year: 2024,
  mileage: 2000,
  company: company4,
  weight: 46000,
  length: 14000,
  height: 2850,
  width: 2550,
  vin: "3AKJHHDR4JSJM4567",
  license_plate: "LMN-9012",
  active: true
)

truck9 = Truck.create!(
  make: "Mack",
  model: "Anthem",
  year: 2020,
  mileage: 25000,
  company: company4,
  weight: 42000,
  length: 13500,
  height: 2600,
  width: 2500,
  vin: "4MACKANTHEM202025",
  license_plate: "MACK-2020",
  active: false # Inactive due to age/mileage
)

# Create shipment statuses
puts "Creating shipment statuses..."

## LogiCo Express statuses
status1_logico = ShipmentStatus.create!(name: "Pre-processing", company: company1, locked_for_customers: false, closed: false)
status2_logico = ShipmentStatus.create!(name: "Ready", company: company1, locked_for_customers: false, closed: false)
status3_logico = ShipmentStatus.create!(name: "Confirmed", company: company1, locked_for_customers: true, closed: false)
status4_logico = ShipmentStatus.create!(name: "In Transit", company: company1, locked_for_customers: true, closed: false)
status5_logico = ShipmentStatus.create!(name: "Delivered", company: company1, locked_for_customers: true, closed: true)

## SnapShip Solutions statuses
status1_snapship = ShipmentStatus.create!(name: "Ready", company: company2, locked_for_customers: true, closed: false)
status2_snapship = ShipmentStatus.create!(name: "In Transit", company: company2, locked_for_customers: true, closed: false)
status3_snapship = ShipmentStatus.create!(name: "Delivered", company: company2, locked_for_customers: true, closed: true)

## FastTrack Freight statuses
status1_fasttrack = ShipmentStatus.create!(name: "Processing", company: company3, locked_for_customers: false, closed: false)
status2_fasttrack = ShipmentStatus.create!(name: "Ready for Pickup", company: company3, locked_for_customers: true, closed: false)
status3_fasttrack = ShipmentStatus.create!(name: "In Transit", company: company3, locked_for_customers: true, closed: false)
status4_fasttrack = ShipmentStatus.create!(name: "Delivered", company: company3, locked_for_customers: true, closed: true)

## Reliable Routes statuses
status1_reliable = ShipmentStatus.create!(name: "Scheduled", company: company4, locked_for_customers: false, closed: false)
status2_reliable = ShipmentStatus.create!(name: "In Transit", company: company4, locked_for_customers: true, closed: false)
status3_reliable = ShipmentStatus.create!(name: "Delivered", company: company4, locked_for_customers: true, closed: true)

# Create shipment action preferences
puts "Creating shipment action preferences..."

## LogiCo Express preferences
ShipmentActionPreference.create!(action: "claimed_by_company", company: company1, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company1, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "out_for_delivery", company: company1, shipment_status: status4_logico)
ShipmentActionPreference.create!(action: "successfully_delivered", company: company1, shipment_status: status5_logico)

## SnapShip Solutions preferences
ShipmentActionPreference.create!(action: "claimed_by_company", company: company2, shipment_status_id: status1_snapship)
ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company2, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "out_for_delivery", company: company2, shipment_status: status2_snapship)
ShipmentActionPreference.create!(action: "successfully_delivered", company: company2, shipment_status: status3_snapship)

## FastTrack Freight preferences
ShipmentActionPreference.create!(action: "claimed_by_company", company: company3, shipment_status_id: status2_fasttrack)
ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company3, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "out_for_delivery", company: company3, shipment_status: status3_fasttrack)
ShipmentActionPreference.create!(action: "successfully_delivered", company: company3, shipment_status: status4_fasttrack)

## Reliable Routes preferences
ShipmentActionPreference.create!(action: "claimed_by_company", company: company4, shipment_status_id: status1_reliable)
ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company4, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "out_for_delivery", company: company4, shipment_status: status2_reliable)
ShipmentActionPreference.create!(action: "successfully_delivered", company: company4, shipment_status: status3_reliable)

# Create shipments with multiple delivery shipments
puts "Creating shipments with delivery history..."

today = Date.today

# Shipment 1: Electronics with multiple delivery attempts
shipment1 = Shipment.create!(
  name: "Electronics Package",
  sender_name: "TechWorld",
  sender_address: "101 Tech Blvd, Silicon Valley, USA",
  receiver_name: "GadgetCo",
  receiver_address: "789 Innovation St, New York, USA",
  weight: 3.5,
  length: 60.0,
  width: 40.0,
  height: 30.0,
  truck: truck1,
  shipment_status: status5_logico,
  user: user10,
  company: company1,
  deliver_by: today + 5.days
)

# Create delivery and delivery shipments for shipment1
delivery1 = Delivery.create!(
  user: user2,
  truck: truck1,
  status: :completed
)

# First delivery attempt (failed)
delivery_shipment1_1 = DeliveryShipment.create!(
  delivery: delivery1,
  shipment: shipment1,
  sender_address: "101 Tech Blvd, Silicon Valley, USA",
  receiver_address: "789 Innovation St, New York, USA",
  loaded_date: 10.days.ago,
  delivered_date: nil # Failed delivery
)

# Second delivery attempt (successful)
delivery_shipment1_2 = DeliveryShipment.create!(
  delivery: delivery1,
  shipment: shipment1,
  sender_address: "789 Innovation St, New York, USA",
  receiver_address: "789 Innovation St, New York, USA",
  loaded_date: 5.days.ago,
  delivered_date: 3.days.ago
)

# Shipment 2: Furniture with single delivery
shipment2 = Shipment.create!(
  name: "Furniture Set",
  sender_name: "FurnitureHub",
  sender_address: "456 Home Decor Ave, Chicago, USA",
  receiver_name: "DecoLuxe",
  receiver_address: "321 Style St, Boston, USA",
  weight: 50.0,
  length: 200.0,
  width: 100.0,
  height: 80.0,
  truck: truck2,
  shipment_status: status5_logico,
  user: user10,
  company: company1,
  deliver_by: today + 3.days
)

delivery2 = Delivery.create!(
  user: user3,
  truck: truck2,
  status: :completed
)

delivery_shipment2 = DeliveryShipment.create!(
  delivery: delivery2,
  shipment: shipment2,
  sender_address: "456 Home Decor Ave, Chicago, USA",
  receiver_address: "321 Style St, Boston, USA",
  loaded_date: 7.days.ago,
  delivered_date: 4.days.ago
)

# Shipment 3: Medical supplies with multiple companies
shipment3 = Shipment.create!(
  name: "Medical Supplies",
  sender_name: "HealthCo",
  sender_address: "123 Wellness St, Denver, USA",
  receiver_name: "MediCenter",
  receiver_address: "456 Care Rd, Austin, USA",
  weight: 8.0,
  length: 80.0,
  width: 60.0,
  height: 50.0,
  truck: truck4,
  shipment_status: status3_snapship,
  user: user11,
  company: company2,
  deliver_by: today + 2.days
)

delivery3 = Delivery.create!(
  user: user5,
  truck: truck4,
  status: :in_progress
)

delivery_shipment3 = DeliveryShipment.create!(
  delivery: delivery3,
  shipment: shipment3,
  sender_address: "123 Wellness St, Denver, USA",
  receiver_address: "456 Care Rd, Austin, USA",
  loaded_date: 1.day.ago,
  delivered_date: nil
)

# Shipment 4: Clothing with multiple delivery attempts
shipment4 = Shipment.create!(
  name: "Fashion Collection",
  sender_name: "FashionHouse",
  sender_address: "100 Style Ave, Miami, USA",
  receiver_name: "Trendy Threads",
  receiver_address: "200 Chic St, Los Angeles, USA",
  weight: 3.0,
  length: 60.0,
  width: 40.0,
  height: 30.0,
  truck: truck6,
  shipment_status: status4_fasttrack,
  user: user12,
  company: company3,
  deliver_by: today + 1.day
)

delivery4 = Delivery.create!(
  user: user7,
  truck: truck6,
  status: :completed
)

# First delivery attempt (wrong address)
delivery_shipment4_1 = DeliveryShipment.create!(
  delivery: delivery4,
  shipment: shipment4,
  sender_address: "100 Style Ave, Miami, USA",
  receiver_address: "150 Chic St, Los Angeles, USA", # Wrong address
  loaded_date: 8.days.ago,
  delivered_date: nil
)

# Second delivery attempt (successful)
delivery_shipment4_2 = DeliveryShipment.create!(
  delivery: delivery4,
  shipment: shipment4,
  sender_address: "150 Chic St, Los Angeles, USA",
  receiver_address: "200 Chic St, Los Angeles, USA",
  loaded_date: 3.days.ago,
  delivered_date: 1.day.ago
)

# Shipment 5: Books with single delivery
shipment5 = Shipment.create!(
  name: "Library Books",
  sender_name: "Library Supplies",
  sender_address: "123 Read Blvd, Portland, USA",
  receiver_name: "City Library",
  receiver_address: "456 Knowledge Ave, Chicago, USA",
  weight: 10.0,
  length: 40.0,
  width: 30.0,
  height: 25.0,
  truck: truck8,
  shipment_status: status3_reliable,
  user: user11,
  company: company4,
  deliver_by: today + 4.days
)

delivery5 = Delivery.create!(
  user: user9,
  truck: truck8,
  status: :completed
)

delivery_shipment5 = DeliveryShipment.create!(
  delivery: delivery5,
  shipment: shipment5,
  sender_address: "123 Read Blvd, Portland, USA",
  receiver_address: "456 Knowledge Ave, Chicago, USA",
  loaded_date: 6.days.ago,
  delivered_date: 2.days.ago
)

# Shipment 6: Sports equipment with multiple delivery attempts
shipment6 = Shipment.create!(
  name: "Sports Equipment",
  sender_name: "SportsPro",
  sender_address: "99 Game Rd, Orlando, USA",
  receiver_name: "PlayNation",
  receiver_address: "88 Fitness Blvd, Atlanta, USA",
  weight: 7.5,
  length: 80.0,
  width: 60.0,
  height: 50.0,
  truck: truck5,
  shipment_status: status3_snapship,
  user: user12,
  company: company2,
  deliver_by: today + 6.days
)

delivery6 = Delivery.create!(
  user: user5,
  truck: truck5,
  status: :completed
)

# First delivery attempt (customer not available)
delivery_shipment6_1 = DeliveryShipment.create!(
  delivery: delivery6,
  shipment: shipment6,
  sender_address: "99 Game Rd, Orlando, USA",
  receiver_address: "88 Fitness Blvd, Atlanta, USA",
  loaded_date: 9.days.ago,
  delivered_date: nil
)

# Second delivery attempt (successful)
delivery_shipment6_2 = DeliveryShipment.create!(
  delivery: delivery6,
  shipment: shipment6,
  sender_address: "88 Fitness Blvd, Atlanta, USA",
  receiver_address: "88 Fitness Blvd, Atlanta, USA",
  loaded_date: 4.days.ago,
  delivered_date: 2.days.ago
)

# ===== NEW ENHANCED DELIVERY SCENARIOS =====

# Shipment 7: Cross-country shipment that passes through multiple companies
puts "Creating complex cross-country shipments..."

shipment7 = Shipment.create!(
  name: "Industrial Equipment",
  sender_name: "ManufacturingCorp",
  sender_address: "500 Industry Blvd, Detroit, USA",
  receiver_name: "Pacific Industries",
  receiver_address: "888 Harbor Way, Los Angeles, USA",
  weight: 25.0,
  length: 180.0,
  width: 120.0,
  height: 100.0,
  truck: truck8,
  shipment_status: status3_reliable,
  user: user10,
  company: company4,
  deliver_by: today + 8.days
)

# First leg: LogiCo picks up and delivers to hub (COMPLETED)
delivery7_1 = Delivery.create!(
  user: user2,
  truck: truck1,
  status: :completed
)

delivery_shipment7_1 = DeliveryShipment.create!(
  delivery: delivery7_1,
  shipment: shipment7,
  sender_address: "500 Industry Blvd, Detroit, USA",
  receiver_address: "456 Transport Blvd, Dallas, USA", # FastTrack hub
  loaded_date: 15.days.ago,
  delivered_date: 12.days.ago
)

# Second leg: FastTrack takes over and delivers to another hub (COMPLETED)
delivery7_2 = Delivery.create!(
  user: user7,
  truck: truck6,
  status: :completed
)

delivery_shipment7_2 = DeliveryShipment.create!(
  delivery: delivery7_2,
  shipment: shipment7,
  sender_address: "456 Transport Blvd, Dallas, USA",
  receiver_address: "789 Cargo Way, Seattle, USA", # Reliable Routes hub
  loaded_date: 11.days.ago,
  delivered_date: 8.days.ago
)

# Third leg: Reliable Routes final delivery (IN PROGRESS)
delivery7_3 = Delivery.create!(
  user: user9,
  truck: truck8,
  status: :in_progress
)

delivery_shipment7_3 = DeliveryShipment.create!(
  delivery: delivery7_3,
  shipment: shipment7,
  sender_address: "789 Cargo Way, Seattle, USA",
  receiver_address: "888 Harbor Way, Los Angeles, USA",
  loaded_date: 2.days.ago,
  delivered_date: nil
)

# Shipment 8: Pharmaceutical shipment with multiple handoffs
shipment8 = Shipment.create!(
  name: "Pharmaceutical Supplies",
  sender_name: "MedPharm Inc",
  sender_address: "200 Pharma Dr, Boston, USA",
  receiver_name: "Regional Hospital",
  receiver_address: "777 Health Plaza, Phoenix, USA",
  weight: 12.0,
  length: 100.0,
  width: 80.0,
  height: 60.0,
  truck: truck5,
  shipment_status: status2_snapship,
  user: user11,
  company: company2,
  deliver_by: today + 3.days
)

# First leg: FastTrack initial pickup and hub delivery (COMPLETED)
delivery8_1 = Delivery.create!(
  user: user7,
  truck: truck6,
  status: :completed
)

delivery_shipment8_1 = DeliveryShipment.create!(
  delivery: delivery8_1,
  shipment: shipment8,
  sender_address: "200 Pharma Dr, Boston, USA",
  receiver_address: "840 Speedy Drive, Miami, USA", # SnapShip hub
  loaded_date: 6.days.ago,
  delivered_date: 4.days.ago
)

# Second leg: SnapShip final delivery (IN PROGRESS)
delivery8_2 = Delivery.create!(
  user: user5,
  truck: truck5,
  status: :in_progress
)

delivery_shipment8_2 = DeliveryShipment.create!(
  delivery: delivery8_2,
  shipment: shipment8,
  sender_address: "840 Speedy Drive, Miami, USA",
  receiver_address: "777 Health Plaza, Phoenix, USA",
  loaded_date: 1.day.ago,
  delivered_date: nil
)

# Shipment 9: Luxury goods with failed delivery requiring re-routing
shipment9 = Shipment.create!(
  name: "Luxury Jewelry Collection",
  sender_name: "Diamond Elite",
  sender_address: "333 Luxury Lane, New York, USA",
  receiver_name: "Prestige Jewelers",
  receiver_address: "555 Elegance St, San Francisco, USA",
  weight: 2.0,
  length: 30.0,
  width: 20.0,
  height: 15.0,
  truck: truck4,
  shipment_status: status2_snapship,
  user: user12,
  company: company2,
  deliver_by: today + 7.days
)

# First attempt: LogiCo failed delivery (security issue) (COMPLETED)
delivery9_1 = Delivery.create!(
  user: user3,
  truck: truck2,
  status: :completed
)

delivery_shipment9_1 = DeliveryShipment.create!(
  delivery: delivery9_1,
  shipment: shipment9,
  sender_address: "333 Luxury Lane, New York, USA",
  receiver_address: "555 Elegance St, San Francisco, USA",
  loaded_date: 10.days.ago,
  delivered_date: nil # Failed - security protocols not met
)

# Second attempt: Re-routed through SnapShip for specialized handling (IN PROGRESS)
delivery9_2 = Delivery.create!(
  user: user5,
  truck: truck4,
  status: :in_progress
)

delivery_shipment9_2 = DeliveryShipment.create!(
  delivery: delivery9_2,
  shipment: shipment9,
  sender_address: "333 Luxury Lane, New York, USA",
  receiver_address: "555 Elegance St, San Francisco, USA",
  loaded_date: 3.days.ago,
  delivered_date: nil
)

# Shipment 10: Automotive parts with express delivery across companies
shipment10 = Shipment.create!(
  name: "Automotive Parts",
  sender_name: "AutoSupply Co",
  sender_address: "150 Motor Pkwy, Detroit, USA",
  receiver_name: "Speed Garage",
  receiver_address: "432 Racing Ave, Las Vegas, USA",
  weight: 18.5,
  length: 120.0,
  width: 80.0,
  height: 70.0,
  truck: truck6,
  shipment_status: status4_fasttrack,
  user: user10,
  company: company3,
  deliver_by: today + 2.days
)

# Single express delivery by FastTrack (COMPLETED)
delivery10 = Delivery.create!(
  user: user7,
  truck: truck6,
  status: :completed
)

delivery_shipment10 = DeliveryShipment.create!(
  delivery: delivery10,
  shipment: shipment10,
  sender_address: "150 Motor Pkwy, Detroit, USA",
  receiver_address: "432 Racing Ave, Las Vegas, USA",
  loaded_date: 5.days.ago,
  delivered_date: 3.days.ago
)

# Shipment 11: Artwork requiring special handling through multiple specialists
shipment11 = Shipment.create!(
  name: "Fine Art Collection",
  sender_name: "Metropolitan Museum",
  sender_address: "100 Museum Mile, New York, USA",
  receiver_name: "West Coast Gallery",
  receiver_address: "250 Art District, Los Angeles, USA",
  weight: 15.0,
  length: 150.0,
  width: 100.0,
  height: 80.0,
  truck: truck1,
  shipment_status: status5_logico,
  user: user11,
  company: company1,
  deliver_by: today + 14.days
)

# First leg: LogiCo climate-controlled transport to hub (COMPLETED)
delivery11_1 = Delivery.create!(
  user: user2,
  truck: truck1,
  status: :completed
)

delivery_shipment11_1 = DeliveryShipment.create!(
  delivery: delivery11_1,
  shipment: shipment11,
  sender_address: "100 Museum Mile, New York, USA",
  receiver_address: "789 Cargo Way, Seattle, USA", # Reliable Routes specialty hub
  loaded_date: 20.days.ago,
  delivered_date: 17.days.ago
)

# Second leg: Reliable Routes final specialized delivery (COMPLETED)
delivery11_2 = Delivery.create!(
  user: user9,
  truck: truck8,
  status: :completed
)

delivery_shipment11_2 = DeliveryShipment.create!(
  delivery: delivery11_2,
  shipment: shipment11,
  sender_address: "789 Cargo Way, Seattle, USA",
  receiver_address: "250 Art District, Los Angeles, USA",
  loaded_date: 16.days.ago,
  delivered_date: 14.days.ago
)

# Shipment 12: Emergency medical supplies with multiple attempts
shipment12 = Shipment.create!(
  name: "Emergency Medical Kit",
  sender_name: "Emergency Supply Corp",
  sender_address: "400 Emergency Blvd, Houston, USA",
  receiver_name: "Rural Clinic",
  receiver_address: "50 Country Rd, Bozeman, USA",
  weight: 6.0,
  length: 70.0,
  width: 50.0,
  height: 40.0,
  truck: truck2,
  shipment_status: status5_logico,
  user: user12,
  company: company1,
  deliver_by: today + 1.day
)

# First attempt: Weather delay (COMPLETED)
delivery12_1 = Delivery.create!(
  user: user3,
  truck: truck2,
  status: :completed
)

delivery_shipment12_1 = DeliveryShipment.create!(
  delivery: delivery12_1,
  shipment: shipment12,
  sender_address: "400 Emergency Blvd, Houston, USA",
  receiver_address: "50 Country Rd, Bozeman, USA",
  loaded_date: 8.days.ago,
  delivered_date: nil # Weather delay
)

# Second attempt: Successful emergency delivery (COMPLETED)
delivery12_2 = Delivery.create!(
  user: user2,
  truck: truck1,
  status: :completed
)

delivery_shipment12_2 = DeliveryShipment.create!(
  delivery: delivery12_2,
  shipment: shipment12,
  sender_address: "400 Emergency Blvd, Houston, USA",
  receiver_address: "50 Country Rd, Bozeman, USA",
  loaded_date: 4.days.ago,
  delivered_date: 2.days.ago
)

# Shipment 13: Technology equipment with sequential company handoffs
shipment13 = Shipment.create!(
  name: "Server Equipment",
  sender_name: "TechManufacturing",
  sender_address: "600 Silicon Way, Austin, USA",
  receiver_name: "DataCenter West",
  receiver_address: "900 Cloud Ave, Seattle, USA",
  weight: 45.0,
  length: 200.0,
  width: 150.0,
  height: 120.0,
  truck: truck4,
  shipment_status: status1_snapship,
  user: user10,
  company: company2,
  deliver_by: today + 5.days
)

# First leg: FastTrack regional transport (COMPLETED)
delivery13_1 = Delivery.create!(
  user: user7,
  truck: truck6,
  status: :completed
)

delivery_shipment13_1 = DeliveryShipment.create!(
  delivery: delivery13_1,
  shipment: shipment13,
  sender_address: "600 Silicon Way, Austin, USA",
  receiver_address: "840 Speedy Drive, Miami, USA", # SnapShip hub for specialized handling
  loaded_date: 7.days.ago,
  delivered_date: 5.days.ago
)

# Second leg: SnapShip scheduled for final delivery
delivery13_2 = Delivery.create!(
  user: user5,
  truck: truck4,
  status: :scheduled
)

delivery_shipment13_2 = DeliveryShipment.create!(
  delivery: delivery13_2,
  shipment: shipment13,
  sender_address: "840 Speedy Drive, Miami, USA",
  receiver_address: "900 Cloud Ave, Seattle, USA",
  loaded_date: nil,
  delivered_date: nil
)

# Create additional shipments for offers
shipment14 = Shipment.create!(
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
  shipment_status: status2_logico,
  user: user10,
  company: company1,
  deliver_by: today + 7.days
)

shipment15 = Shipment.create!(
  name: "Toys and Games",
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
  user: user11,
  company: nil,
  deliver_by: today + 10.days
)

shipment16 = Shipment.create!(
  name: "Office Supplies",
  sender_name: "OfficeMart",
  sender_address: "987 Work Ave, Philadelphia, USA",
  receiver_name: "BizSupply",
  receiver_address: "121 Productivity Blvd, Las Vegas, USA",
  weight: 3.14,
  length: 50.0,
  width: 40.0,
  height: 30.0,
  truck: nil,
  shipment_status: nil,
  user: user12,
  company: nil,
  deliver_by: today + 8.days
)

# Create offers from multiple companies
puts "Creating offers from multiple companies..."

# Offers for shipment15 (unclaimed)
Offer.create!(
  shipment: shipment15,
  company: company1,
  status: :issued,
  reception_address: "101 Fun St, Minneapolis, USA",
  pickup_from_sender: true,
  deliver_to_door: true,
  dropoff_location: "555 Happy Blvd, Charlotte, USA",
  pickup_at_dropoff: false,
  price: 45.50,
  notes: "Fast delivery guaranteed"
)

Offer.create!(
  shipment: shipment15,
  company: company2,
  status: :issued,
  reception_address: "101 Fun St, Minneapolis, USA",
  pickup_from_sender: false,
  deliver_to_door: true,
  dropoff_location: "555 Happy Blvd, Charlotte, USA",
  pickup_at_dropoff: false,
  price: 20.00,
  notes: "Competitive pricing"
)

Offer.create!(
  shipment: shipment15,
  company: company3,
  status: :issued,
  reception_address: "101 Fun St, Minneapolis, USA",
  pickup_from_sender: true,
  deliver_to_door: false,
  dropoff_location: "555 Happy Blvd, Charlotte, USA",
  pickup_at_dropoff: false,
  price: 80.75,
  notes: "Premium service with tracking"
)

# Offers for shipment16 (unclaimed)
Offer.create!(
  shipment: shipment16,
  company: company2,
  status: :issued,
  reception_address: "987 Work Ave, Philadelphia, USA",
  pickup_from_sender: true,
  deliver_to_door: true,
  dropoff_location: "121 Productivity Blvd, Las Vegas, USA",
  pickup_at_dropoff: false,
  price: 85.25,
  notes: "Reliable delivery service"
)

Offer.create!(
  shipment: shipment16,
  company: company4,
  status: :issued,
  reception_address: "987 Work Ave, Philadelphia, USA",
  pickup_from_sender: false,
  deliver_to_door: true,
  dropoff_location: "121 Productivity Blvd, Las Vegas, USA",
  pickup_at_dropoff: false,
  price: 65.00,
  notes: "Best value for money"
)

# Create ratings for companies
puts "Creating ratings for companies..."

# Ratings for LogiCo Express
Rating.create!(
  company: company1,
  user: user10,
  delivery_shipment: delivery_shipment1_2,
  stars: 4,
  comment: "Good service, but first delivery attempt failed. Second attempt was perfect!"
)

Rating.create!(
  company: company1,
  user: user10,
  delivery_shipment: delivery_shipment2,
  stars: 5,
  comment: "Excellent delivery service. Furniture arrived in perfect condition."
)

Rating.create!(
  company: company1,
  user: user11,
  delivery_shipment: delivery_shipment11_1,
  stars: 5,
  comment: "Perfect climate-controlled transport for our artwork. Highly professional."
)

Rating.create!(
  company: company1,
  user: user12,
  delivery_shipment: delivery_shipment12_2,
  stars: 5,
  comment: "Excellent emergency response! Got our medical supplies delivered despite weather delays."
)

# Ratings for SnapShip Solutions
Rating.create!(
  company: company2,
  user: user12,
  delivery_shipment: delivery_shipment6_2,
  stars: 3,
  comment: "Delivery was delayed, but eventually arrived safely."
)

Rating.create!(
  company: company2,
  user: user12,
  delivery_shipment: delivery_shipment9_2,
  stars: 4,
  comment: "Much better security protocols than previous carrier. Jewelry arrived safely."
)

Rating.create!(
  company: company2,
  user: user11,
  delivery_shipment: delivery_shipment8_2,
  stars: 4,
  comment: "Good handling of pharmaceutical supplies. Temperature controlled as requested."
)

# Ratings for FastTrack Freight
Rating.create!(
  company: company3,
  user: user12,
  delivery_shipment: delivery_shipment4_2,
  stars: 4,
  comment: "Good service, but had to correct the delivery address."
)

Rating.create!(
  company: company3,
  user: user10,
  delivery_shipment: delivery_shipment10,
  stars: 5,
  comment: "Fantastic express service! Automotive parts arrived exactly when needed."
)

Rating.create!(
  company: company3,
  user: user11,
  delivery_shipment: delivery_shipment8_1,
  stars: 4,
  comment: "Reliable first leg of cross-country pharmaceutical delivery."
)

# Ratings for Reliable Routes
Rating.create!(
  company: company4,
  user: user11,
  delivery_shipment: delivery_shipment5,
  stars: 5,
  comment: "Perfect delivery service. Books arrived on time and in excellent condition."
)

Rating.create!(
  company: company4,
  user: user10,
  delivery_shipment: delivery_shipment7_3,
  stars: 4,
  comment: "Great final leg service for our industrial equipment cross-country shipment."
)

Rating.create!(
  company: company4,
  user: user11,
  delivery_shipment: delivery_shipment11_2,
  stars: 5,
  comment: "Exceptional specialized handling for fine art. White glove service!"
)

# Create forms for trucks and deliveries
puts "Creating forms..."

# Maintenance form for inactive truck
Form.create!(
  user: user1,
  company: company1,
  title: "Truck Maintenance Report",
  form_type: "Maintenance",
  submitted_at: 2.days.ago,
  formable: truck3,
  content: {
    mileage: 15000,
    oil_changed: true,
    tire_pressure_checked: true,
    last_inspection_date: 6.months.ago.to_date,
    notes: "Truck needs major maintenance. Brake system needs replacement."
  }
)

# Maintenance form for another inactive truck
Form.create!(
  user: user6,
  company: company3,
  title: "Truck Maintenance Report",
  form_type: "Maintenance",
  submitted_at: 1.day.ago,
  formable: truck7,
  content: {
    mileage: 25000,
    oil_changed: true,
    tire_pressure_checked: true,
    last_inspection_date: 7.months.ago.to_date,
    notes: "Engine showing signs of wear. Recommend full inspection."
  }
)

# Pre-delivery inspection form
Form.create!(
  user: user2,
  company: company1,
  title: "Pre-delivery Inspection",
  form_type: "Pre-delivery Inspection",
  submitted_at: 10.days.ago,
  formable: delivery1,
  content: {
    start_time: 10.days.ago
  }
)

# Delivery form
Form.create!(
  user: user3,
  company: company1,
  title: "Delivery Report",
  form_type: "Delivery",
  submitted_at: 4.days.ago,
  formable: delivery2,
  content: {
    destination: "321 Style St, Boston, USA",
    start_time: 7.days.ago,
    items: [ "Furniture Set", "Assembly Instructions" ]
  }
)

# Create additional shipments for variety
puts "Creating additional shipments..."

Shipment.create!([
  {
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
    shipment_status: status2_logico,
    user: user10,
    company: company1,
    deliver_by: today + 12.days
  },

  {
    name: "Bicycles",
    sender_name: "CycleWorks",
    sender_address: "222 Pedal Rd, Columbus, USA",
    receiver_name: "RideFast",
    receiver_address: "333 Trail Ln, Memphis, USA",
    weight: 15.0,
    length: 150.0,
    width: 30.0,
    height: 80.0,
    truck: nil,
    shipment_status: nil,
    user: user11,
    company: nil,
    deliver_by: today + 15.days
  },

  {
    name: "Groceries",
    sender_name: "FreshFoods",
    sender_address: "555 Market St, Omaha, USA",
    receiver_name: "DailyMart",
    receiver_address: "444 Grocery Ln, Kansas City, USA",
    weight: 5.0,
    length: 50.0,
    width: 40.0,
    height: 30.0,
    truck: nil,
    shipment_status: nil,
    user: user12,
    company: nil,
    deliver_by: today + 9.days
  },

  {
    name: "Pet Supplies",
    sender_name: "PawPalace",
    sender_address: "789 Bark Blvd, St. Louis, USA",
    receiver_name: "FurryFriends",
    receiver_address: "888 Woof Way, Indianapolis, USA",
    weight: 4.1,
    length: 60.0,
    width: 50.0,
    height: 40.0,
    truck: nil,
    shipment_status: nil,
    user: user10,
    company: nil,
    deliver_by: today + 11.days
  },

  {
    name: "Cosmetics",
    sender_name: "BeautyGlow",
    sender_address: "234 Glam Ave, Detroit, USA",
    receiver_name: "MakeUpMart",
    receiver_address: "777 Chic St, Louisville, USA",
    weight: 2.5,
    length: 50.0,
    width: 40.0,
    height: 30.0,
    truck: nil,
    shipment_status: nil,
    user: user11,
    company: nil,
    deliver_by: today + 13.days
  },

  {
    name: "Scientific Instruments",
    sender_name: "LabTech Solutions",
    sender_address: "123 Research Pkwy, Cambridge, USA",
    receiver_name: "University Lab",
    receiver_address: "456 Campus Dr, Berkeley, USA",
    weight: 8.5,
    length: 90.0,
    width: 60.0,
    height: 50.0,
    truck: nil,
    shipment_status: nil,
    user: user12,
    company: nil,
    deliver_by: today + 16.days
  },

  {
    name: "Restaurant Equipment",
    sender_name: "Commercial Kitchen Co",
    sender_address: "789 Chef Way, Chicago, USA",
    receiver_name: "Bistro Downtown",
    receiver_address: "321 Culinary St, Portland, USA",
    weight: 35.0,
    length: 180.0,
    width: 120.0,
    height: 90.0,
    truck: nil,
    shipment_status: nil,
    user: user10,
    company: nil,
    deliver_by: today + 18.days
  }
])

puts "Seeding complete!"
puts "Created:"
puts "  - #{Company.count} companies"
puts "  - #{User.count} users"
puts "  - #{Truck.count} trucks (#{Truck.where(active: true).count} active, #{Truck.where(active: false).count} inactive)"
puts "  - #{Shipment.count} shipments"
puts "  - #{Delivery.count} deliveries"
puts "  - #{DeliveryShipment.count} delivery shipments"
puts "  - #{Offer.count} offers"
puts "  - #{Rating.count} ratings"
puts "  - #{Form.count} forms"
puts "  - #{ShipmentStatus.count} shipment statuses"
puts "  - #{ShipmentActionPreference.count} shipment action preferences"

puts "\nDelivery Scenarios Created:"
puts "  - Simple single-company deliveries"
puts "  - Multiple delivery attempts within same company"
puts "  - Cross-country shipments through multiple companies"
puts "  - Failed deliveries with re-routing"
puts "  - Emergency deliveries with weather delays"
puts "  - Specialized cargo (art, pharmaceuticals, luxury goods)"
puts "  - Express deliveries"
puts "  - Sequential company handoffs"
