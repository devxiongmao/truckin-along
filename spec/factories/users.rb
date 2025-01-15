FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password" }
    password_confirmation { "password" }
    first_name { "John" }
    last_name { "Doe" }
    drivers_license { Faker::Alphanumeric.alphanumeric(number: 8, min_alpha: 2).upcase }
    role { :driver } # Default role, change as needed

    trait :admin do
      role { :admin }
    end

    trait :driver do
      role { :driver }
    end
  end
end
