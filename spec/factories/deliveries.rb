FactoryBot.define do
  factory :delivery do
    association :truck
    association :user
    status { :scheduled }
  end
end
