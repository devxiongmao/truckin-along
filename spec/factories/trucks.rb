FactoryBot.define do
  factory :truck do
    make { "#{Faker::Vehicle.manufacture} #{SecureRandom.uuid}" }
    model { Faker::Vehicle.model }
    year { Faker::Vehicle.year }
    mileage { Faker::Number.between(from: 10_000, to: 500_000) }
    weight { Faker::Number.decimal(l_digits: 4, r_digits: 1) }
    length { Faker::Number.decimal(l_digits: 3, r_digits: 1) }
    width { Faker::Number.decimal(l_digits: 3, r_digits: 1) }
    height { Faker::Number.decimal(l_digits: 3, r_digits: 1) }
    vin { Faker::Vehicle.vin }
    license_plate { Faker::Vehicle.license_plate }
    association :company
  end
end
