FactoryBot.define do
  factory :truck do
    make { "Volvo" }
    model { "VNL" }
    year { 2021 }
    mileage { 120000 }
    association :company
  end
end
