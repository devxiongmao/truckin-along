# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
Shipment.destroy_all
ShipmentStatus.destroy_all
Truck.destroy_all
User.destroy_all
Company.destroy_all

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
  weight: 18000, # in kilograms
  length: 1000.5,
  height: 300.9,
  width: 200.5,
  vin: "1HGCM82633A004352",
  license_plate: "ABC-1234"
)

truck2 = Truck.create!(
  make: "Scania",
  model: "R500",
  year: 2021,
  mileage: 12000,
  company: company1,
  weight: 19000, # in kilograms
  length: 1100.0,
  height: 400.0,
  width: 200.5,
  vin: "2C3KA53G76H123456",
  license_plate: "XYZ-9876"
)

truck3 = Truck.create!(
  make: "Kenworth",
  model: "T680",
  year: 2020,
  mileage: 15000,
  company: company1,
  weight: 18500, # in kilograms
  length: 1000.8,
  height: 300.8,
  width: 200.5,
  vin: "5N1AR18B98C765432",
  license_plate: "LMN-4567"
)

truck4 = Truck.create!(
  make: "Peterbilt",
  model: "579",
  year: 2019,
  mileage: 18000,
  company: company1,
  weight: 18700, # in kilograms
  length: 1000.6,
  height: 300.9,
  width: 200.5,
  vin: "JH4KA9650MC012345",
  license_plate: "QWE-8523"
)

truck5 = Truck.create!(
  make: "Freightliner",
  model: "Cascadia",
  year: 2022,
  mileage: 8000,
  company: company1,
  weight: 18300, # in kilograms
  length: 1100.2,
  height: 300.95,
  width: 200.5,
  vin: "WDBRF61J43F234567",
  license_plate: "JKL-3698"
)

truck6 = Truck.create!(
  make: "Volvo",
  model: "VNL 760",
  year: 2023,
  mileage: 5000,
  company: company2,
  weight: 18500, # in kilograms
  length: 1120.5,
  height: 310.75,
  width: 205.3,
  vin: "1M8GDM9A8KP042788",
  license_plate: "XYZ-1234"
)

truck7 = Truck.create!(
  make: "Kenworth",
  model: "T681",
  year: 2021,
  mileage: 12000,
  company: company2,
  weight: 17900, # in kilograms
  length: 1085.4,
  height: 295.6,
  width: 198.7,
  vin: "2HSCUAPR47C537921",
  license_plate: "ABC-5678"
)

truck8 = Truck.create!(
  make: "Peterbilt",
  model: "580",
  year: 2024,
  mileage: 2000,
  company: company2,
  weight: 19000, # in kilograms
  length: 1150.9,
  height: 320.4,
  width: 210.1,
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

ShipmentActionPreference.create!(action: "claimed_by_company", company: company2, shipment_status_id: status4)
ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company2, shipment_status_id: nil)
ShipmentActionPreference.create!(action: "out_for_delivery", company: company2, shipment_status: status2)

# Create shipments
puts "Creating shipments..."
Shipment.create!(
  name: "Electronics",
  sender_name: "TechWorld",
  sender_address: "101 Tech Blvd, Silicon Valley, USA",
  receiver_name: "GadgetCo",
  receiver_address: "789 Innovation St, New York, USA",
  weight: 120.5,
  boxes: 10,
  length: 200.0,
  width: 100.2,
  height: 100.0,
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
  weight: 250.8,
  boxes: 5,
  length: 300.0,
  width: 100.5,
  height: 200.0,
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
  weight: 250.0,
  boxes: 15,
  length: 200.5,
  width: 100.2,
  height: 100.5,
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
  weight: 300.5,
  boxes: 8,
  length: 300.5,
  width: 200.0,
  height: 200.5,
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
  weight: 180.7,
  boxes: 20,
  length: 200.2,
  width: 100.5,
  height: 100.2,
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
  weight: 95.0,
  boxes: 30,
  length: 100.5,
  width: 100.0,
  height: 100.0,
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
  weight: 200.3,
  boxes: 40,
  length: 100.8,
  width: 100.2,
  height: 100.0,
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
  weight: 170.2,
  boxes: 12,
  length: 200.5,
  width: 100.2,
  height: 100.5,
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
  weight: 310.0,
  boxes: 18,
  length: 200.8,
  width: 100.5,
  height: 200.0,
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
  weight: 140.9,
  boxes: 25,
  length: 200.0,
  width: 100.2,
  height: 100.3,
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
  weight: 140.9,
  boxes: 2,
  length: 200.0,
  width: 100.2,
  height: 100.3,
  truck: nil,
  shipment_status: nil,
  user: user6,
  company: nil
)

Shipment.create!([
  { name: "Electronics", sender_name: "ElectroCorp", sender_address: "500 Circuit Ave, San Jose, USA", receiver_name: "TechMart", receiver_address: "222 Innovation Dr, Austin, USA", weight: 320.5, boxes: 45, length: 250.0, width: 110.5, height: 120.0, truck: nil, shipment_status: nil, user: user5, company: nil },
  { name: "Books", sender_name: "ReadMore", sender_address: "88 Library Ln, Boston, USA", receiver_name: "BookWorld", receiver_address: "777 Novel St, Seattle, USA", weight: 200.0, boxes: 30, length: 180.0, width: 90.0, height: 95.5, truck: nil, shipment_status: nil, user: user5, company: company2 },
  { name: "Furniture", sender_name: "HomeComfort", sender_address: "99 Cozy Rd, Chicago, USA", receiver_name: "HouseStyle", receiver_address: "333 Living Way, Miami, USA", weight: 450.0, boxes: 15, length: 300.0, width: 150.0, height: 200.0, truck: nil, shipment_status: nil, user: user5, company: company2 },
  { name: "Clothing", sender_name: "FashionHub", sender_address: "123 Trendy Ave, New York, USA", receiver_name: "WearItAll", receiver_address: "444 Runway St, Los Angeles, USA", weight: 180.7, boxes: 50, length: 170.0, width: 80.0, height: 90.0, truck: nil, shipment_status: nil, user: user5, company: nil },
  { name: "Sports Equipment", sender_name: "AthletiCo", sender_address: "456 Fit St, Denver, USA", receiver_name: "ActiveZone", receiver_address: "888 Play Blvd, Phoenix, USA", weight: 220.3, boxes: 20, length: 200.0, width: 100.0, height: 110.0, truck: nil, shipment_status: nil, user: user5, company: nil },
  { name: "Appliances", sender_name: "KitchenPro", sender_address: "789 Cook Ln, Houston, USA", receiver_name: "HomeNeeds", receiver_address: "666 Utility Rd, Dallas, USA", weight: 500.0, boxes: 10, length: 280.0, width: 130.0, height: 150.0, truck: nil, shipment_status: nil, user: user5, company: nil },
  { name: "Garden Tools", sender_name: "GreenThumb", sender_address: "321 Bloom Dr, Portland, USA", receiver_name: "GrowMore", receiver_address: "111 Nature St, San Diego, USA", weight: 160.0, boxes: 18, length: 190.0, width: 85.0, height: 95.0, truck: nil, shipment_status: nil, user: user6, company: nil },
  { name: "Medical Supplies", sender_name: "MediCare", sender_address: "654 Health St, Atlanta, USA", receiver_name: "Wellness Center", receiver_address: "999 Recovery Rd, Nashville, USA", weight: 210.5, boxes: 25, length: 220.0, width: 110.0, height: 120.0, truck: nil, shipment_status: nil, user: user6, company: nil },
  { name: "Toys", sender_name: "ToyFactory", sender_address: "101 Fun St, Minneapolis, USA", receiver_name: "KidsLand", receiver_address: "555 Happy Blvd, Charlotte, USA", weight: 140.9, boxes: 25, length: 200.0, width: 100.2, height: 100.3, truck: nil, shipment_status: nil, user: user5, company: nil },
  { name: "Office Supplies", sender_name: "OfficeMart", sender_address: "987 Work Ave, Philadelphia, USA", receiver_name: "BizSupply", receiver_address: "121 Productivity Blvd, Las Vegas, USA", weight: 130.6, boxes: 35, length: 160.0, width: 75.0, height: 85.0, truck: nil, shipment_status: nil, user: user6, company: nil },
  { name: "Bicycles", sender_name: "CycleWorks", sender_address: "222 Pedal Rd, Columbus, USA", receiver_name: "RideFast", receiver_address: "333 Trail Ln, Memphis, USA", weight: 250.0, boxes: 12, length: 260.0, width: 100.0, height: 130.0, truck: nil, shipment_status: nil, user: user6, company: company2 },
  { name: "Groceries", sender_name: "FreshFoods", sender_address: "555 Market St, Omaha, USA", receiver_name: "DailyMart", receiver_address: "444 Grocery Ln, Kansas City, USA", weight: 280.5, boxes: 50, length: 200.0, width: 120.0, height: 100.0, truck: nil, shipment_status: nil, user: user6, company: nil },
  { name: "Pet Supplies", sender_name: "PawPalace", sender_address: "789 Bark Blvd, St. Louis, USA", receiver_name: "FurryFriends", receiver_address: "888 Woof Way, Indianapolis, USA", weight: 150.2, boxes: 22, length: 190.0, width: 90.0, height: 95.0, truck: nil, shipment_status: nil, user: user6, company: company2 },
  { name: "Cosmetics", sender_name: "BeautyGlow", sender_address: "234 Glam Ave, Detroit, USA", receiver_name: "MakeUpMart", receiver_address: "777 Chic St, Louisville, USA", weight: 120.0, boxes: 28, length: 150.0, width: 70.0, height: 80.0, truck: nil, shipment_status: nil, user: user6, company: company2 }
])


puts "Seeding complete!"
