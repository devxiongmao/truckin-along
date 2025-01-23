FactoryBot.define do
  factory :truck do
    make { "Volvo" }
    model { "VNL" }
    year { 2021 }
    mileage { 120000 }
    weight { 2500.0 }
    length { 500.0 }
    width { 200.0 }
    height { 250.0 }
    association :company
  end
end
