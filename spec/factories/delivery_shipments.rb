FactoryBot.define do
  factory :delivery_shipment do
    association :delivery
    association :shipment

    sender_address { Faker::Address.full_address }
    receiver_address { Faker::Address.full_address }
  end
end
