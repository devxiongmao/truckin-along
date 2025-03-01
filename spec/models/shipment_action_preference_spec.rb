require 'rails_helper'

RSpec.describe ShipmentActionPreference, type: :model do
  # Setup for tests
  let(:company) { create(:company) }
  let(:shipment_status) { create(:shipment_status) }

  # Create a valid preference for testing
  let(:valid_attributes) do
    {
      company: company,
      shipment_status: shipment_status,
      action: "claimed_by_company"
    }
  end

  describe "associations" do
    it { should belong_to(:company) }
    it { should belong_to(:shipment_status).optional }
  end

  describe "validations" do
    subject { ShipmentActionPreference.new(valid_attributes) }

    it { should validate_inclusion_of(:action).in_array(ShipmentActionPreference::ACTIONS) }
    it { should validate_uniqueness_of(:action).scoped_to(:company_id) }
  end

  describe "uniqueness constraint" do
    before do
      ShipmentActionPreference.create!(
        company: company,
        action: "claimed_by_company"
      )
    end

    it "prevents duplicate action for the same company" do
      duplicate = ShipmentActionPreference.new(
        company: company,
        action: "claimed_by_company"
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:action]).to include("has already been taken")
    end

    it "allows the same action for different companies" do
      other_company = create(:company)
      preference = ShipmentActionPreference.new(
        company: other_company,
        action: "claimed_by_company"
      )
      expect(preference).to be_valid
    end

    it "allows different actions for the same company" do
      preference = ShipmentActionPreference.new(
        company: company,
        action: "loaded_onto_truck"
      )
      expect(preference).to be_valid
    end
  end

  describe "constants" do
    it "defines the expected ACTIONS" do
      expected_actions = [
        "claimed_by_company",
        "loaded_onto_truck",
        "out_for_delivery"
      ]
      expect(ShipmentActionPreference::ACTIONS).to match_array(expected_actions)
    end
  end
end
