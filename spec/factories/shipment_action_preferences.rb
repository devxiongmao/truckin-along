FactoryBot.define do
  factory :shipment_action_preference do
    action { "departing_warehouse" }
    association :company
    association :shipment_status
  end
end
