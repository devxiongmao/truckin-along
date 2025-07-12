require 'rails_helper'

RSpec.describe DeliveryShipment, type: :model do
  # Define a valid delivery_shipment object for reuse
  let(:valid_delivery) { create(:delivery_shipment) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to belong_to(:shipment) }
    it { is_expected.to belong_to(:delivery).optional }
    it { is_expected.to have_one(:rating).dependent(:destroy) }
  end

  ## Geocoding Tests
  describe "geocoding" do
    describe "sender address geocoding" do
      it "geocodes the sender address on create" do
        new_delivery_shipment = build(:delivery_shipment, sender_address: "123 New Street, New York, NY")
        new_delivery_shipment.save

        expect(new_delivery_shipment.sender_latitude).to eq(40.7128)
        expect(new_delivery_shipment.sender_longitude).to eq(-74.0060)
      end

      it "geocodes the sender address when sender_address changes" do
        valid_delivery.sender_address = "456 Changed Street, New York, NY"
        valid_delivery.save

        expect(valid_delivery.sender_latitude).to eq(40.7128)
        expect(valid_delivery.sender_longitude).to eq(-74.0060)
      end

      it "handles nil results from geocoder" do
        allow(Geocoder).to receive(:search).and_return([])

        valid_delivery.sender_address = "Invalid Address"
        valid_delivery.save

        expect(valid_delivery.sender_latitude).to be_nil
        expect(valid_delivery.sender_longitude).to be_nil
      end
    end

    describe "receiver address geocoding" do
      it "geocodes the receiver address on create" do
        new_delivery_shipment = build(:delivery_shipment, receiver_address: "123 New Street, New York, NY")
        new_delivery_shipment.save

        expect(new_delivery_shipment.receiver_latitude).to eq(40.7128)
        expect(new_delivery_shipment.receiver_longitude).to eq(-74.0060)
      end

      it "geocodes the receiver address when receiver_address changes" do
        valid_delivery.receiver_address = "456 Changed Street, New York, NY"
        valid_delivery.save

        expect(valid_delivery.receiver_latitude).to eq(40.7128)
        expect(valid_delivery.receiver_longitude).to eq(-74.0060)
      end

      it "handles nil results from geocoder" do
        allow(Geocoder).to receive(:search).and_return([])

        valid_delivery.receiver_address = "Invalid Address"
        valid_delivery.save

        expect(valid_delivery.receiver_latitude).to be_nil
        expect(valid_delivery.receiver_longitude).to be_nil
      end
    end
  end
end
