require 'rails_helper'

RSpec.describe GeocodeDeliveryShipmentsJob, type: :job do
  let(:sender_address) { "1600 Amphitheatre Parkway, Mountain View, CA" }
  let(:receiver_address) { "1 Infinite Loop, Cupertino, CA" }

  let!(:shipment) do
    create(:delivery_shipment, sender_address: sender_address, receiver_address: receiver_address)
  end

  it 'updates coordinates for sender and receiver' do
    described_class.new.perform([ shipment.id ])

    shipment.reload
    expect(shipment.sender_latitude).to eq 40.7128
    expect(shipment.sender_longitude).to eq -74.006
    expect(shipment.receiver_latitude).to eq 40.7128
    expect(shipment.receiver_longitude).to eq -74.006
  end

  it 'raises error if Geocoder fails, triggering Sidekiq retry' do
    allow(Geocoder).to receive(:search).with(sender_address).and_raise(StandardError.new("Boom"))

    expect {
      described_class.new.perform([ shipment.id ])
    }.to raise_error(StandardError)
  end

  it 'logs and raises when rate limited' do
    allow(Geocoder).to receive(:search).with(sender_address).and_raise(Geocoder::OverQueryLimitError.new("Rate limit"))

    expect(Rails.logger).to receive(:warn).with(/Rate limited by Geocoder/)

    expect {
      described_class.new.perform([ shipment.id ])
    }.to raise_error(Geocoder::OverQueryLimitError)
  end
end
