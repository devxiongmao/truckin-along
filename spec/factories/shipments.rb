FactoryBot.define do
  factory :shipment do
    name { "Test Shipment" }
    sender_name { "John Doe" }
    sender_address { "123 Sender St, Sender City" }
    receiver_name { "Jane Smith" }
    receiver_address { '456 Receiver Ave, Receiver City' }
    weight { 100.5 }
    length { 12.5 }
    width { 7.5 }
    height { 10.0 }
    boxes { 10 }
    association :truck
    association :shipment_status
    association :user
    association :company
  end
end
