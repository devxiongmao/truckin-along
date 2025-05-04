FactoryBot.define do
  factory :delivery do
    association :truck
    association :user
    status { :in_progress }
  end
end
