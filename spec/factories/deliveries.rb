FactoryBot.define do
  factory :delivery do
    association :truck
    association :user
  end
end
  