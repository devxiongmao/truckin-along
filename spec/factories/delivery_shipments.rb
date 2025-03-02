FactoryBot.define do
  factory :delivery_shipment do
    association :delivery
    association :shipment
  end
end
