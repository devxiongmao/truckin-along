FactoryBot.define do
  factory :shipment do
    name { Faker::Commerce.product_name }
    sender_name { Faker::Name.name }
    sender_address { Faker::Address.full_address }
    receiver_name { Faker::Name.name }
    receiver_address { Faker::Address.full_address }
    weight { Faker::Number.decimal(l_digits: 3, r_digits: 1) }
    length { Faker::Number.decimal(l_digits: 2, r_digits: 1) }
    width { Faker::Number.decimal(l_digits: 2, r_digits: 1) }
    height { Faker::Number.decimal(l_digits: 2, r_digits: 1) }

    association :truck
    association :shipment_status
    association :user
    association :company
  end
end
