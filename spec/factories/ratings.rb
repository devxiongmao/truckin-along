FactoryBot.define do
  factory :rating do
    stars { rand(1..5) }
    comment { Faker::Lorem.sentence }
    association :user
    association :company
    association :delivery_shipment
  end
end
