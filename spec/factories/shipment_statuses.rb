FactoryBot.define do
  factory :shipment_status do
    name { Faker::Commerce.product_name }
    locked_for_customers { false }
    association :company
  end
end
