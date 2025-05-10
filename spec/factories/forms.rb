FactoryBot.define do
  factory :form do
    association :user
    association :company
    title { Faker::Lorem.sentence(word_count: 3) }
    form_type { "Maintenance" } # Default to "Maintenance" unless overridden
    submitted_at { Faker::Time.between(from: 30.days.ago, to: Time.current) }

    # Default formable association (will be overridden by traits)
    # By default, associate with a truck for maintenance forms
    after(:build) do |form, evaluator|
      if form.formable.nil?
        truck = evaluator.formable || create(:truck)
        form.formable = truck
        form.formable_type = "Truck"
        form.formable_id = truck.id
      end
    end

    # Transient attribute to allow passing custom content without overwriting defaults
    transient do
      custom_content { {} }
      formable { nil }
    end

    # ✅ Pre-Delivery Form
    trait :pre_delivery do
      form_type { "Pre-delivery Inspection" }
      content do
        {
          "start_time" => Faker::Time.between(from: 3.days.ago, to: Time.current)
        }.merge(custom_content) # Merge user overrides
      end

      # Set formable to a delivery
      after(:build) do |form, evaluator|
        delivery = evaluator.formable || create(:delivery)
        form.formable = delivery
        form.formable_type = "Delivery"
        form.formable_id = delivery.id
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

      # Set formable to a truck
      after(:build) do |form, evaluator|
        truck = evaluator.formable || create(:truck)
        form.formable = truck
        form.formable_type = "Truck"
        form.formable_id = truck.id
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

      # Set formable to a delivery
      after(:build) do |form, evaluator|
        delivery = evaluator.formable || create(:delivery)
        form.formable = delivery
        form.formable_type = "Delivery"
        form.formable_id = delivery.id
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

      # Set formable to a truck (assuming hazmat forms are associated with trucks)
      # Change this if hazmat forms should be associated with something else
      after(:build) do |form, evaluator|
        truck = evaluator.formable || create(:truck)
        form.formable = truck
        form.formable_type = "Truck"
        form.formable_id = truck.id
      end
    end
  end
end
