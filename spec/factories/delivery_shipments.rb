FactoryBot.define do
  factory :delivery_shipment do
    association :delivery
    association :shipment

    sender_address { Faker::Address.full_address }
    receiver_address { Faker::Address.full_address }
    loaded_date { Faker::Time.between(from: 30.days.ago, to: Time.current) }
    delivered_date { nil }
  end
end
