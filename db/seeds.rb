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

# Create users
puts "Creating users..."
user1 = User.create!(
  email: "john.doe@example.com",
  password: "password123",
  first_name: "John",
  last_name: "Doe",
  drivers_license: "D1234567",
  role: 1,
  company: company1
)

user2 = User.create!(
  email: "jane.smith@example.com",
  password: "password123",
  first_name: "Jane",
  last_name: "Smith",
  drivers_license: "S7654321",
  role: 0,
  company: company1
)


user3 = User.create!(
  email: "michael.jordan@example.com",
  password: "password123",
  first_name: "Michael",
  last_name: "Jordan",
  drivers_license: "MJ123456",
  role: 0,
  company: company1
)

user4 = User.create!(
  email: "sarah.connor@example.com",
  password: "password123",
  first_name: "Sarah",
  last_name: "Connor",
  drivers_license: "SC654321",
  role: 0,
  company: company1
)

user5 = User.create!(
  email: "peter.parker@example.com",
  password: "password123",
  first_name: "Peter",
  last_name: "Parker",
  drivers_license: "PP987654",
  role: 0,
  company: company1
)

# Create trucks
puts "Creating trucks..."
truck1 = Truck.create!(make: "Volvo", model: "FH16", year: 2022, mileage: 5000, company: company1)
truck2 = Truck.create!(make: "Scania", model: "R500", year: 2021, mileage: 12000, company: company1)
truck3 = Truck.create!(make: "Kenworth", model: "T680", year: 2020, mileage: 15000, company: company1)
truck4 = Truck.create!(make: "Peterbilt", model: "579", year: 2019, mileage: 18000, company: company1)
truck5 = Truck.create!(make: "Freightliner", model: "Cascadia", year: 2022, mileage: 8000, company: company1)

# Create shipment statuses
puts "Creating shipment statuses..."
status1 = ShipmentStatus.create!(name: "Ready", company: company1)
status2 = ShipmentStatus.create!(name: "In Transit", company: company1)
status3 = ShipmentStatus.create!(name: "Delivered", company: company1)

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
  truck: truck1,
  shipment_status: status1,
  user: user1,
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
  truck: truck2,
  shipment_status: status2,
  user: user2,
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
  truck: truck1,
  shipment_status: status1,
  user: nil,
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
  truck: truck1,
  shipment_status: status1,
  user: nil,
  company: company1
)

Shipment.create!(
  name: "Clothing",
  sender_name: "FashionHouse",
  sender_address: "100 Style Ave, Miami, USA",
  receiver_name: "Trendy Threads",
  receiver_address: "200 Chic St, Los Angeles, USA",
  weight: 180.7,
  boxes: 20,
  truck: truck1,
  shipment_status: status1,
  user: nil,
  company: company1
)

Shipment.create!(
  name: "Electronics Accessories",
  sender_name: "GadgetMart",
  sender_address: "55 Tech St, San Francisco, USA",
  receiver_name: "ElectroWorld",
  receiver_address: "77 Digital Rd, Dallas, USA",
  weight: 95.0,
  boxes: 30,
  truck: nil,
  shipment_status: status1,
  user: nil,
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
  truck: nil,
  shipment_status: status1,
  user: nil,
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
  truck: nil,
  shipment_status: status1,
  user: nil,
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
  truck: nil,
  shipment_status: status1,
  user: nil,
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
  truck: nil,
  shipment_status: status1,
  user: nil,
  company: company1
)

puts "Seeding complete!"
