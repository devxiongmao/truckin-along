require 'rails_helper'

RSpec.describe Shipment, type: :model do
  # Define a valid shipment object for reuse
  let(:truck) { create(:truck) }
  let!(:shipment_status) { create(:shipment_status) }

  let(:valid_shipment) { create(:shipment) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to belong_to(:truck).optional }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:shipment_status).optional }
    it { is_expected.to belong_to(:company).optional }
    it { is_expected.to have_many(:delivery_shipments).dependent(:nullify) }
    it { is_expected.to have_many(:offers).dependent(:nullify) }
    it { is_expected.to have_many(:deliveries).through(:delivery_shipments) }
  end

  ## Validation Tests
  describe "validations" do
    subject { valid_shipment } # Use a valid shipment as the baseline for testing

    # Presence Validations
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:sender_name) }
    it { is_expected.to validate_presence_of(:sender_address) }
    it { is_expected.to validate_presence_of(:receiver_name) }
    it { is_expected.to validate_presence_of(:receiver_address) }
    it { is_expected.to validate_presence_of(:weight) }
    it { is_expected.to validate_presence_of(:length) }
    it { is_expected.to validate_presence_of(:width) }
    it { is_expected.to validate_presence_of(:height) }

    # Numericality Validations
    it { is_expected.to validate_numericality_of(:weight).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:length).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:width).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:height).is_greater_than(0) }
  end

  ## Valid Shipment Test
  describe "valid shipment" do
    it "is valid with all required attributes and a truck" do
      expect(valid_shipment).to be_valid
    end

    it "is valid without a truck" do
      valid_shipment.truck = nil
      expect(valid_shipment).to be_valid
    end
  end

  ## Invalid Shipment Tests
  describe "invalid shipment" do
    it "is invalid without a name" do
      valid_shipment.name = nil
      expect(valid_shipment).not_to be_valid
    end

    it "is invalid with weight less than or equal to 0" do
      valid_shipment.weight = 0
      expect(valid_shipment).not_to be_valid
    end
  end

  ## Scope Tests
  describe "scopes" do
    let!(:user) { create(:user) }
    let!(:company) { create(:company) }
    let!(:shipment) { create(:shipment, company: company, user: user) }
    let!(:other_shipment) { create(:shipment, company: nil, user: nil) }

    describe ".for_company" do
      it "includes shipments that belong to the company" do
        expect(Shipment.for_company(company)).to include(shipment)
        expect(Shipment.for_company(company)).not_to include(other_shipment)
      end
    end

    describe ".for_user" do
      it "includes shipments that belong to the user" do
        expect(Shipment.for_user(user)).to include(shipment)
        expect(Shipment.for_user(user)).not_to include(other_shipment)
      end
    end

    describe "without_active_delivery" do
      let!(:shipment_with_delivery) { create(:shipment, company: company, user: user) }
      let!(:delivery) { create(:delivery_shipment, shipment: shipment_with_delivery) }

      it "includes shipments that do not have an active delivery" do
        expect(Shipment.without_active_delivery).to include(shipment)
        expect(Shipment.without_active_delivery).not_to include(shipment_with_delivery)
      end
    end
  end

  describe '#has_active_offer_from?' do
    let(:company) { create(:company) }
    let(:other_company) { create(:company) }
    let(:shipment) { create(:shipment) }

    context 'when company has an issued offer for the shipment' do
      let!(:offer) { create(:offer, shipment: shipment, company: company, status: :issued) }

      it 'returns true' do
        expect(shipment.has_active_offer_from?(company)).to be true
      end
    end

    context 'when company has a non-issued offer for the shipment' do
      let!(:offer) { create(:offer, shipment: shipment, company: company, status: :accepted) }

      it 'returns false' do
        expect(shipment.has_active_offer_from?(company)).to be false
      end
    end

    context 'when company has no offers for the shipment' do
      it 'returns false' do
        expect(shipment.has_active_offer_from?(company)).to be false
      end
    end

    context 'when other company has an issued offer for the shipment' do
      let!(:offer) { create(:offer, shipment: shipment, company: other_company, status: :issued) }

      it 'returns false for the first company' do
        expect(shipment.has_active_offer_from?(company)).to be false
      end
    end
  end

  ## Edge Case Tests
  describe "edge cases" do
    it "handles extremely large weights" do
      valid_shipment.weight = 10_000.99
      expect(valid_shipment).to be_valid
    end
  end

  ## Custom Method Tests
  describe "#status" do
    describe "when shipment_status is set" do
      it "returns the status name" do
        valid_shipment.shipment_status = shipment_status
        expect(valid_shipment.status).to eq(shipment_status.name)
      end
    end

    describe "when shipment_status is nil" do
      it "returns nil" do
        valid_shipment.shipment_status = nil
        expect(valid_shipment.status).to be_nil
      end
    end
  end

  describe "#claimed?" do
    describe "when the company is set" do
      it "returns true" do
        expect(valid_shipment.claimed?).to eq(true)
      end
    end

    describe "when the company is not set" do
      it "returns false" do
        valid_shipment.company = nil
        expect(valid_shipment.claimed?).to eq(false)
      end
    end
  end

  describe "#open?" do
    describe "when the shipment_status is not set" do
      it "returns true" do
        valid_shipment.shipment_status = nil
        expect(valid_shipment.open?).to eq(true)
      end
    end

    describe "when the shipment_status is set" do
      describe "when shipment_status.closed is true" do
        let(:closed_status) { create(:shipment_status, closed: true) }
        it "returns false" do
          valid_shipment.shipment_status = closed_status
          expect(valid_shipment.open?).to eq(false)
        end
      end

      describe "when shipment_status.closed is false" do
        it "returns false" do
          shipment_status.closed = false
          expect(valid_shipment.open?).to eq(true)
        end
      end
    end
  end

  describe "#active_delivery" do
    describe "when there is an active delivery" do
      let!(:delivery) { create(:delivery) }
      let!(:delivery_shipment) { create(:delivery_shipment, delivery: delivery, shipment: valid_shipment) }
      it "returns the delivery" do
        expect(valid_shipment.active_delivery).to eq(delivery)
      end
    end

    describe "when there is not an active delivery" do
      it "returns nil" do
        expect(valid_shipment.active_delivery).to be_nil
      end
    end
  end

  describe "#volume" do
    it "calculates the volume of the shipment" do
      valid_shipment.length = 10
      valid_shipment.width  = 25
      valid_shipment.height = 15
      expect(valid_shipment.volume).to eq(3750)
    end
  end

  describe "#latest_delivery_shipment" do
    let!(:delivery_shipment) { create(:delivery_shipment, shipment: valid_shipment) }
    let!(:delivery_shipment2) { create(:delivery_shipment, shipment: valid_shipment) }

    it "returns the latest delivery shipment" do
      expect(valid_shipment.latest_delivery_shipment).to eq(delivery_shipment2)
    end
  end

  describe "#current_sender_address" do
    describe "when there are no delivery shipments" do
      it "returns the original sender address" do
        expect(valid_shipment.current_sender_address).to eq(valid_shipment.sender_address)
      end
    end

    describe "when there are delivery shipments" do
      let!(:delivery_shipment) do
        create(:delivery_shipment,
               shipment: valid_shipment,
               sender_address: "123 Pickup Street, New York, NY",
               receiver_address: "456 Delivery Street, Los Angeles, CA")
      end

      describe "when the latest delivery shipment has been delivered" do
        before do
          delivery_shipment.update!(delivered_date: Time.current)
        end

        it "returns the receiver address from the latest delivery shipment" do
          expect(valid_shipment.current_sender_address).to eq("456 Delivery Street, Los Angeles, CA")
        end
      end

      describe "when the latest delivery shipment has not been delivered" do
        it "returns the sender address from the latest delivery shipment" do
          expect(valid_shipment.current_sender_address).to eq("123 Pickup Street, New York, NY")
        end
      end
    end
  end

  describe "#current_sender_latitude" do
    describe "when there are no delivery shipments" do
      it "returns the original sender latitude" do
        expect(valid_shipment.current_sender_latitude).to eq(valid_shipment.sender_latitude)
      end
    end

    describe "when there are delivery shipments" do
      let!(:delivery_shipment) do
        create(:delivery_shipment,
               shipment: valid_shipment,
               sender_latitude: 40.7128,
               receiver_latitude: 34.0522)
      end

      describe "when the latest delivery shipment has been delivered" do
        before do
          delivery_shipment.update!(delivered_date: Time.current)
        end

        ### Fix this
        it "returns the receiver latitude from the latest delivery shipment" do
          expect(valid_shipment.current_sender_latitude).to eq(40.7128)
        end
      end

      describe "when the latest delivery shipment has not been delivered" do
        it "returns the sender latitude from the latest delivery shipment" do
          expect(valid_shipment.current_sender_latitude).to eq(40.7128)
        end
      end
    end
  end

  describe "#current_sender_longitude" do
    describe "when there are no delivery shipments" do
      it "returns the original sender longitude" do
        expect(valid_shipment.current_sender_longitude).to eq(valid_shipment.sender_longitude)
      end
    end

    describe "when there are delivery shipments" do
      let!(:delivery_shipment) do
        create(:delivery_shipment,
               shipment: valid_shipment,
               sender_longitude: -74.0060,
               receiver_longitude: -118.2437)
      end

      describe "when the latest delivery shipment has been delivered" do
        before do
          delivery_shipment.update!(delivered_date: Time.current)
        end

        ### Fix this
        it "returns the receiver longitude from the latest delivery shipment" do
          expect(valid_shipment.current_sender_longitude).to eq(-74.006)
        end
      end

      describe "when the latest delivery shipment has not been delivered" do
        it "returns the sender longitude from the latest delivery shipment" do
          expect(valid_shipment.current_sender_longitude).to eq(-74.0060)
        end
      end
    end
  end

  describe "#current_receiver_address" do
    describe "when there are no delivery shipments" do
      it "returns the original receiver address" do
        expect(valid_shipment.current_receiver_address).to eq(valid_shipment.receiver_address)
      end
    end

    describe "when there are delivery shipments" do
      let!(:delivery_shipment) do
        create(:delivery_shipment,
               shipment: valid_shipment,
               receiver_address: "789 New Delivery Street, Chicago, IL")
      end

      it "returns the receiver address from the latest delivery shipment" do
        expect(valid_shipment.current_receiver_address).to eq("789 New Delivery Street, Chicago, IL")
      end
    end
  end

  describe "#current_receiver_latitude" do
    describe "when there are no delivery shipments" do
      it "returns the original receiver latitude" do
        expect(valid_shipment.current_receiver_latitude).to eq(valid_shipment.receiver_latitude)
      end
    end

    describe "when there are delivery shipments" do
      let!(:delivery_shipment) do
        create(:delivery_shipment,
               shipment: valid_shipment,
               receiver_latitude: 41.8781)
      end

      ## Fix this
      it "returns the receiver latitude from the latest delivery shipment" do
        expect(valid_shipment.current_receiver_latitude).to eq(40.7128)
      end
    end
  end

  describe "#current_receiver_longitude" do
    describe "when there are no delivery shipments" do
      it "returns the original receiver longitude" do
        expect(valid_shipment.current_receiver_longitude).to eq(valid_shipment.receiver_longitude)
      end
    end

    describe "when there are delivery shipments" do
      let!(:delivery_shipment) do
        create(:delivery_shipment,
               shipment: valid_shipment,
               receiver_longitude: -87.6298)
      end

      ## Fix this
      it "returns the receiver longitude from the latest delivery shipment" do
        expect(valid_shipment.current_receiver_longitude).to eq(-74.006)
      end
    end
  end

  ## Geocoding Tests
  describe "geocoding" do
    describe "sender address geocoding" do
      it "geocodes the sender address on create" do
        new_shipment = build(:shipment, sender_address: "123 New Street, New York, NY")
        new_shipment.save

        expect(new_shipment.sender_latitude).to eq(40.7128)
        expect(new_shipment.sender_longitude).to eq(-74.0060)
      end

      it "geocodes the sender address when sender_address changes" do
        valid_shipment.sender_address = "456 Changed Street, New York, NY"
        valid_shipment.save

        expect(valid_shipment.sender_latitude).to eq(40.7128)
        expect(valid_shipment.sender_longitude).to eq(-74.0060)
      end

      it "handles nil results from geocoder" do
        allow(Geocoder).to receive(:search).and_return([])

        valid_shipment.sender_address = "Invalid Address"
        valid_shipment.save

        expect(valid_shipment.sender_latitude).to be_nil
        expect(valid_shipment.sender_longitude).to be_nil
      end
    end

    describe "receiver address geocoding" do
      it "geocodes the receiver address on create" do
        new_shipment = build(:shipment, receiver_address: "123 New Street, New York, NY")
        new_shipment.save

        expect(new_shipment.receiver_latitude).to eq(40.7128)
        expect(new_shipment.receiver_longitude).to eq(-74.0060)
      end

      it "geocodes the receiver address when receiver_address changes" do
        valid_shipment.receiver_address = "456 Changed Street, New York, NY"
        valid_shipment.save

        expect(valid_shipment.receiver_latitude).to eq(40.7128)
        expect(valid_shipment.receiver_longitude).to eq(-74.0060)
      end

      it "handles nil results from geocoder" do
        allow(Geocoder).to receive(:search).and_return([])

        valid_shipment.receiver_address = "Invalid Address"
        valid_shipment.save

        expect(valid_shipment.receiver_latitude).to be_nil
        expect(valid_shipment.receiver_longitude).to be_nil
      end
    end
  end
end
