FactoryBot.define do
  factory :user do
    email { "test@example.com" }
    password { "password" }
    password_confirmation { "password" }
    first_name { "John" }
    last_name { "Doe" }
    role { :driver } # Default role, change as needed

    trait :admin do
      role { :admin }
    end

    trait :driver do
      role { :driver }
    end
  end
end
