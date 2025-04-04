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
end
