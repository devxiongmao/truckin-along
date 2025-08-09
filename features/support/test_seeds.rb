# db/seeds/test_seeds.rb
module TestSeeds
  def self.load
    # Clear existing data
    Shipment.destroy_all
    ShipmentStatus.destroy_all
    Truck.destroy_all
    User.destroy_all
    Company.destroy_all
    ShipmentActionPreference.destroy_all

    company1 = Company.create!(name: "LogiCo", address: "123 Logistics Lane, Springfield, USA")

    # Admin
    User.create!(
      email: "john.doe@example.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe",
      drivers_license: "D1234567",
      role: :admin, # assuming enum: { admin: 0, driver: 1, customer: 2 }
      home_address: "505 Developer Way, Palo Alto, USA",
      company: company1
    )

    # Driver
    User.create!(
      email: "jane.smith@example.com",
      password: "password123",
      first_name: "Jane",
      last_name: "Smith",
      drivers_license: "S7654321",
      role: :driver,
      home_address: "202 Innovation Ave, Silicon Valley, USA",
      company: company1
    )

    # Customer
    User.create!(
      email: "peter.parker@example.com",
      password: "password123",
      first_name: "Peter",
      last_name: "Parker",
      drivers_license: "PP987654",
      role: :customer,
      home_address: "101 Tech Blvd, Silicon Valley, USA",
      company: nil
    )

    %w[claimed_by_company loaded_onto_truck out_for_delivery successfully_delivered].each do |action|
      ShipmentActionPreference.create!(action: action, company: company1, shipment_status: nil)
    end
  end
end
