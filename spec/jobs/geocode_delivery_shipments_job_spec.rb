require 'rails_helper'

RSpec.describe GeocodeDeliveryShipmentsJob, type: :job do
  let(:sender_address) { "1600 Amphitheatre Parkway, Mountain View, CA" }
  let(:receiver_address) { "1 Infinite Loop, Cupertino, CA" }

  let (:delivery_shipment) { create(:delivery_shipment, sender_address: sender_address, receiver_address: receiver_address) }

  it 'updates coordinates for sender and receiver' do
    described_class.new.perform([ delivery_shipment.id ])

    delivery_shipment.reload
    expect(delivery_shipment.sender_latitude).to eq 40.7128
    expect(delivery_shipment.sender_longitude).to eq -74.006
    expect(delivery_shipment.receiver_latitude).to eq 40.7128
    expect(delivery_shipment.receiver_longitude).to eq -74.006
  end

  it 'raises error if Geocoder fails, triggering Sidekiq retry' do
    allow(Geocoder).to receive(:search).with(sender_address).and_raise(StandardError.new("Boom"))

    expect {
      described_class.new.perform([ shipment.id ])
    }.to raise_error(StandardError)
  end

  it 'raises when rate limited' do
    allow(Geocoder).to receive(:search).with(sender_address).and_raise(Geocoder::OverQueryLimitError.new("Rate limit"))

    expect {
      described_class.new.perform([ delivery_shipment.id ])
    }.to raise_error(Geocoder::OverQueryLimitError)
  end
end
