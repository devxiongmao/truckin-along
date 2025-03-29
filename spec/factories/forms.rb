FactoryBot.define do
  factory :form do
    association :user
    association :company
    association :truck
    association :delivery

    title { Faker::Lorem.sentence(word_count: 3) }
    form_type { "Maintenance" } # Default to "Maintenance" unless overridden
    submitted_at { Faker::Time.between(from: 30.days.ago, to: Time.current) }

    # Transient attribute to allow passing custom content without overwriting defaults
    transient do
      custom_content { {} }
    end

    # ✅ Pre-Delivery Form
    trait :pre_delivery do
      form_type { "Pre-delivery Inspection" }
      content do
        {
          "start_time" => Faker::Time.between(from: 3.days.ago, to: Time.current)
        }.merge(custom_content) # Merge user overrides
      end
    end


    # ✅ Maintenance Form
    trait :maintenance do
      form_type { "Maintenance" }
      content do
        {
          "mileage" => Faker::Number.number(digits: 6),
          "oil_changed" => Faker::Boolean.boolean,
          "tire_pressure_checked" => Faker::Boolean.boolean,
          "last_inspection_date" => Faker::Time.between(from: 8.months.ago, to: Time.current),
          "notes" => Faker::Lorem.sentence
        }.merge(custom_content) # Merge user overrides
      end
    end

    # ✅ Delivery Form
    trait :delivery do
      form_type { "Delivery" }
      content do
        {
          "destination" => Faker::Address.street_address,
          "start_time" => Faker::Time.between(from: 10.days.ago, to: Time.current),
          "items" => [
            { "name" => "Package A", "weight" => "5kg" },
            { "name" => "Package B", "weight" => "10kg" }
          ]
        }.merge(custom_content)
      end
    end

    # ✅ Hazmat Form
    trait :hazmat do
      form_type { "Hazmat" }
      content do
        {
          "shipment_id" => Faker::Number.number(digits: 4),
          "hazardous_materials" => [
            { "type" => "Battery", "properly_stored" => Faker::Boolean.boolean },
            { "type" => "Chemical", "properly_stored" => Faker::Boolean.boolean }
          ],
          "inspection_passed" => Faker::Boolean.boolean
        }.merge(custom_content)
      end
    end
  end
end