require 'rails_helper'

RSpec.describe Truck, type: :model do
  # Define a valid truck object for reuse
  let(:valid_truck) { create(:truck) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to have_many(:shipments) }
    it { is_expected.to belong_to(:company) }
  end

  ## Validation Tests
  describe "validations" do
    subject { valid_truck } # Use a valid truck as the baseline for testing

    # Presence Validations
    it { is_expected.to validate_presence_of(:make) }
    it { is_expected.to validate_presence_of(:model) }
    it { is_expected.to validate_presence_of(:length) }
    it { is_expected.to validate_presence_of(:width) }
    it { is_expected.to validate_presence_of(:height) }
    it { is_expected.to validate_presence_of(:weight) }

    # Numericality Validations
    it { is_expected.to validate_numericality_of(:length).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:width).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:height).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:weight).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:year).only_integer }
    it { is_expected.to validate_numericality_of(:year).is_greater_than_or_equal_to(1900) }
    it { is_expected.to validate_numericality_of(:mileage).only_integer }
    it { is_expected.to validate_numericality_of(:mileage).is_greater_than_or_equal_to(0) }
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
      expect(valid_truck.display_name).to eq("#{valid_truck.make}-#{valid_truck.model}-#{valid_truck.year}")
    end

    it "handles nil values gracefully" do
      valid_truck.make = nil
      valid_truck.model = nil
      valid_truck.year = nil
      expect(valid_truck.display_name).to eq("--")
    end
  end
end
