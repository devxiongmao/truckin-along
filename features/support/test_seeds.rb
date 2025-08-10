# db/seeds/test_seeds.rb
module TestSeeds
  def self.load
    # Clear existing data
    Rating.destroy_all
    DeliveryShipment.destroy_all
    Delivery.destroy_all
    Offer.destroy_all
    Form.destroy_all
    ShipmentStatus.destroy_all
    Truck.destroy_all
    ShipmentActionPreference.destroy_all
    Shipment.destroy_all
    User.destroy_all
    Company.destroy_all

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

    [ company1, company2, company3, company4 ].each do |company|
      %w[claimed_by_company loaded_onto_truck out_for_delivery successfully_delivered].each do |action|
        ShipmentActionPreference.create!(action: action, company: company, shipment_status: nil)
      end
    end

    ## Shipments
    today = Date.today
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
      truck: nil,
      shipment_status: nil,
      user: user10,
      company: nil,
      deliver_by: today + 5.days
    )

    # Create offers from multiple companies
    puts "Creating offers from multiple companies..."

    # Offers for shipment1 (unclaimed)
    Offer.create!(
      shipment: shipment1,
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
      shipment: shipment1,
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
      shipment: shipment1,
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
  end
end
