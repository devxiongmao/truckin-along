FactoryBot.define do
  factory :form do
    association :user
    association :company
    title { Faker::Lorem.sentence(word_count: 3) }
    form_type { %w[Delivery Maintenance Hazmat].sample }
    submitted_at { Faker::Time.between(from: 30.days.ago, to: Time.current) }

    # Dynamic JSON content based on form_type
    content do
      case form_type
      when "Delivery"
        {
          destination: Faker::Address.street_address,
          start_time: Faker::Time.between(from: 10.days.ago, to: Time.current),
          items: [
            { name: "Package A", weight: "5kg" },
            { name: "Package B", weight: "10kg" }
          ]
        }
      when "Maintenance"
        {
          mileage: Faker::Number.number(digits: 6),
          oil_changed: Faker::Boolean.boolean,
          tire_pressure_checked: Faker::Boolean.boolean,
          notes: Faker::Lorem.sentence
        }
      when "Hazmat"
        {
          shipment_id: Faker::Number.number(digits: 4),
          hazardous_materials: [
            { type: "Battery", properly_stored: Faker::Boolean.boolean },
            { type: "Chemical", properly_stored: Faker::Boolean.boolean }
          ],
          inspection_passed: Faker::Boolean.boolean
        }
      else
        {}
      end
    end
  end
end
