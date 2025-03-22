FactoryBot.define do
  factory :company do
    name { "#{Faker::Company.name} #{SecureRandom.uuid}" }
    address { Faker::Address.full_address }
  end
end
