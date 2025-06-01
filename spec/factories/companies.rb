FactoryBot.define do
  factory :company do
    name { "#{Faker::Company.name} #{SecureRandom.uuid}" }
    address { Faker::Address.full_address }
    phone_number { "+1#{Faker::Number.number(digits: 10)}" }
  end
end
