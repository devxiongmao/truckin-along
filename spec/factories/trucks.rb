FactoryBot.define do
  factory :truck do
    make { Faker::Vehicle.manufacture }
    model { Faker::Vehicle.model }
    year { Faker::Vehicle.year }
    mileage { Faker::Number.between(from: 10_000, to: 500_000) }
    weight { Faker::Number.decimal(l_digits: 4, r_digits: 1) }
    length { Faker::Number.decimal(l_digits: 3, r_digits: 1) }
    width { Faker::Number.decimal(l_digits: 3, r_digits: 1) }
    height { Faker::Number.decimal(l_digits: 3, r_digits: 1) }
    association :company
  end
end
