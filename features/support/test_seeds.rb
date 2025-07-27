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

    # Driver
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

    # Customer
    user3 = User.create!(
      email: "peter.parker@example.com",
      password: "password123",
      first_name: "Peter",
      last_name: "Parker",
      drivers_license: "PP987654",
      role: 2,
      home_address: "101 Tech Blvd, Silicon Valley, USA",
      company: nil
    )

    ShipmentActionPreference.create!(action: "claimed_by_company", company: company1, shipment_status_id: nil)
    ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company1, shipment_status_id: nil)
    ShipmentActionPreference.create!(action: "out_for_delivery", company: company1, shipment_status: nil)
    ShipmentActionPreference.create!(action: "successfully_delivered", company: company1, shipment_status: nil)
  end
end
