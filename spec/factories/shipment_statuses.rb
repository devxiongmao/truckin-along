FactoryBot.define do
  factory :shipment_status do
    name { "Ready" }
    association :company
  end
end
