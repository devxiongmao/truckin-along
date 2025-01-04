require 'rails_helper'

RSpec.describe Truck, type: :model do
  # Define a valid truck object for reuse
  let(:valid_truck) do
    Truck.new(
      make: "Volvo",
      model: "VNL",
      year: 2021,
      mileage: 120000
    )
  end

  ## Association Tests
  describe "associations" do
    it { is_expected.to have_many(:shipments) }
  end

  ## Validation Tests
  describe "validations" do
    subject { valid_truck } # Use a valid truck as the baseline for testing

    # Presence Validations
    it { is_expected.to validate_presence_of(:make) }
    it { is_expected.to validate_presence_of(:model) }

    # Numericality Validations
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
end
