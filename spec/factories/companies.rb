FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    address { Faker::Address.full_address }
  end
end