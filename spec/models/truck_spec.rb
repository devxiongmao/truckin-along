require 'rails_helper'

RSpec.describe Truck, type: :model do
  # Define a valid truck object for reuse
  let(:valid_truck) { create(:truck) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to have_many(:shipments) }
    it { is_expected.to have_many(:deliveries).dependent(:nullify) }
    it { is_expected.to belong_to(:company) }
  end

  ## Validation Tests
  describe "validations" do
    subject { valid_truck } # Use a valid truck as the baseline for testing

    # Uniqueness Validations
    it { is_expected.to validate_uniqueness_of(:vin) }

    # Presence Validations
    it { is_expected.to validate_presence_of(:make) }
    it { is_expected.to validate_presence_of(:model) }
    it { is_expected.to validate_presence_of(:length) }
    it { is_expected.to validate_presence_of(:width) }
    it { is_expected.to validate_presence_of(:height) }
    it { is_expected.to validate_presence_of(:weight) }
    it { is_expected.to validate_presence_of(:license_plate) }
    it { is_expected.to validate_presence_of(:vin) }

    # Numericality Validations
    it { is_expected.to validate_numericality_of(:length).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:width).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:height).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:weight).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:year).only_integer }
    it { is_expected.to validate_numericality_of(:year).is_greater_than_or_equal_to(1900) }
    it { is_expected.to validate_numericality_of(:mileage).only_integer }
    it { is_expected.to validate_numericality_of(:mileage).is_greater_than_or_equal_to(0) }

    it { is_expected.to validate_length_of(:vin).is_equal_to(17) }
  end

  ## Valid Truck Test
  describe "valid truck" do
    it "is valid with all required attributes" do
      expect(valid_truck).to be_valid
    end
  end

  ## Invalid Truck Tests
  describe "invalid truck" do
    it "is invalid without a make" do
      valid_truck.make = nil
      expect(valid_truck).not_to be_valid
    end

    it "is invalid without a model" do
      valid_truck.model = nil
      expect(valid_truck).not_to be_valid
    end

    it "is invalid with a year less than 1900" do
      valid_truck.year = 1899
      expect(valid_truck).not_to be_valid
    end

    it "is invalid with a negative mileage" do
      valid_truck.mileage = -1
      expect(valid_truck).not_to be_valid
    end
  end

  ## Edge Case Tests
  describe "edge cases" do
    it "allows mileage of zero" do
      valid_truck.mileage = 0
      expect(valid_truck).to be_valid
    end

    it "handles extremely large mileage values" do
      valid_truck.mileage = 1_000_000
      expect(valid_truck).to be_valid
    end

    it "does not allow non-integer values for year" do
      valid_truck.year = 2021.5
      expect(valid_truck).not_to be_valid
    end
  end

  ## Custom Method Tests
  describe "#display_name" do
    it "returns a string formatted as make-model-year" do
      expect(valid_truck.display_name).to eq("#{valid_truck.make}-#{valid_truck.model}-#{valid_truck.year}(#{valid_truck.license_plate})")
    end

    it "handles nil values gracefully" do
      valid_truck.make = nil
      valid_truck.model = nil
      valid_truck.year = nil
      valid_truck.license_plate = nil

      expect(valid_truck.display_name).to eq("--()")
    end
  end

  describe "#available?" do
    describe "when there is an active delivery" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }
      it "returns false" do
        expect(valid_truck.available?).to eq(false)
      end
    end

    describe "when there is not an active delivery" do
      it "returns true" do
        expect(valid_truck.available?).to eq(true)
      end
    end
  end

  describe "#active_delivery" do
    describe "when there is an active delivery" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }
      it "returns the delivery" do
        expect(valid_truck.active_delivery).to eq(delivery)
      end
    end

    describe "when there is not an active delivery" do
      it "returns nil" do
        expect(valid_truck.active_delivery).to be_nil
      end
    end
  end

  describe "#volume" do
    it "calculates the volume of the truck bed" do
      valid_truck.length = 13600
      valid_truck.height = 2800
      valid_truck.width = 2550
      expect(valid_truck.volume).to eq(97104000000)
    end
  end

  describe "#current_shipments" do
    let!(:open_status) { create(:shipment_status, closed: false) }
    let!(:closed_status) { create(:shipment_status, closed: true) }

    let!(:shipment1) { create(:shipment, truck: valid_truck, shipment_status: open_status) }
    let!(:shipment2) { create(:shipment, truck: valid_truck, shipment_status: closed_status) }
    it "returns the open shipments" do
      expect(valid_truck.current_shipments).to eq([ shipment1 ])
    end
  end

  describe "#current_volume" do
    let!(:shipment_status) { create(:shipment_status, closed: false) }
    let!(:shipment1) { create(:shipment, truck: valid_truck, shipment_status: shipment_status) }
    let!(:shipment2) { create(:shipment, truck: valid_truck, shipment_status: shipment_status) }
    it "calculates the current volume of the truck bed" do
      expect(valid_truck.current_volume).to eq(shipment1.volume + shipment2.volume)
    end
  end

  describe "#current_weight" do
    let!(:shipment_status) { create(:shipment_status, closed: false) }
    let!(:shipment1) { create(:shipment, truck: valid_truck, shipment_status: shipment_status) }
    let!(:shipment2) { create(:shipment, truck: valid_truck, shipment_status: shipment_status) }
    it "calculates the current volume of the truck bed" do
      expect(valid_truck.current_weight).to eq(shipment1.weight + shipment2.weight)
    end
  end
end
