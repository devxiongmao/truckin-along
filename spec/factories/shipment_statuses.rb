FactoryBot.define do
  factory :shipment_status do
    name { "#{Faker::Commerce.product_name} #{SecureRandom.uuid}" }
    locked_for_customers { false }
    association :company
  end
end
