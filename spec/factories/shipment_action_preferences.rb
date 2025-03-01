FactoryBot.define do
  factory :shipment_action_preference do
    action { "claimed_by_company" }
    association :company
    association :shipment_status
  end
end
