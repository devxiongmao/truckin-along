FactoryBot.define do
  factory :shipment_status do
    name { Faker::Commerce.product_name }
    association :company
  end
end
