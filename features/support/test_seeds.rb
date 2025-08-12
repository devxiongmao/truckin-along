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

    ## Shipment Statuses
    status5_logico = ShipmentStatus.create!(
      name: "Delivered",
      company: company1,
      locked_for_customers: true,
      closed: true
    )

    ## LogiCo Express preferences
    ShipmentActionPreference.create!(action: "claimed_by_company", company: company1, shipment_status_id: nil)
    ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company1, shipment_status_id: nil)
    ShipmentActionPreference.create!(action: "out_for_delivery", company: company1, shipment_status: nil)
    ShipmentActionPreference.create!(action: "successfully_delivered", company: company1, shipment_status: status5_logico)

    ## SnapShip Solutions preferences
    ShipmentActionPreference.create!(action: "claimed_by_company", company: company2, shipment_status_id: nil)
    ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company2, shipment_status_id: nil)
    ShipmentActionPreference.create!(action: "out_for_delivery", company: company2, shipment_status: nil)
    ShipmentActionPreference.create!(action: "successfully_delivered", company: company2, shipment_status: nil)

    ## FastTrack Freight preferences
    ShipmentActionPreference.create!(action: "claimed_by_company", company: company3, shipment_status_id: nil)
    ShipmentActionPreference.create!(action: "loaded_onto_truck", company: company3, shipment_status_id: nil)
    ShipmentActionPreference.create!(action: "out_for_delivery", company: company3, shipment_status: nil)
    ShipmentActionPreference.create!(action: "successfully_delivered", company: company3, shipment_status: nil)


    # Create trucks
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

    ## Forms
    form1 = Form.create!(
      user: user1,
      company: company1,
      title: "Maintenance Check",
      form_type: "Maintenance",
      content: { notes: "Nothing of note to report", mileage: 4500, oil_changed: true, last_inspection_date: "2025-08-11", tire_pressure_checked: true },
      submitted_at: "2025-08-12 01:34:10.996113000 +0000",
      formable: truck1
    )

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

    ## Shipment that has been moved by two companies
    shipment2 = Shipment.create!(
      name: "Documents",
      sender_name: "Peter Parker",
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

    # Deliveries
    delivery1 = Delivery.create!(
      user: user1,
      truck: truck1,
      status: :completed
    )

    # DeliveryShipments
    deliveryShipment1 = DeliveryShipment.create!(
      delivery: delivery1,
      shipment: shipment2,
      sender_address: "101 Fun St, Minneapolis, USA",
      receiver_address: "555 Happy Blvd, Charlotte, USA",
      sender_latitude: 44.993139,
      sender_longitude: -93.2491445,
      receiver_latitude: 41.2645606,
      receiver_longitude: -95.9965907,
      loaded_date: "2025-08-12 01:36:07.081448000 +0000",
      delivered_date: "2025-08-12 01:42:45.705674000 +0000"
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
