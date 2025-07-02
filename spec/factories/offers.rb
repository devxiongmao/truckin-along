FactoryBot.define do
  factory :offer do
    reception_address { Faker::Address.full_address }
    pickup_from_sender { false }
    deliver_to_door { true }
    dropoff_location { Faker::Address.full_address }
    pickup_at_dropoff { false }
    price { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    notes { Faker::Lorem.sentence }
    status { :issued }

    association :shipment
    association :company

    trait :accepted do
      status { :accepted }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :issued do
      status { :issued }
    end
  end
end
