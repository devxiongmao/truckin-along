require 'rails_helper'

RSpec.describe ShipmentStatus, type: :model do
  let(:company) { create(:company) }
  let(:shipment_status) { create(:shipment_status, company: company) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to have_many(:shipments).dependent(:nullify) }
    it { is_expected.to belong_to(:company) }
    it { should have_many(:shipment_action_preferences).dependent(:nullify) }
  end

  ## Validation Tests
  describe "validations" do
    subject { shipment_status } # Use a valid ShipmentStatus as the baseline for testing

    # Presence Validations
    it { is_expected.to validate_presence_of(:name) }
  end

  ## Valid ShipmentStatus Test
  describe "valid shipment status" do
    it "is valid with a name" do
      expect(shipment_status).to be_valid
    end
  end

  ## Invalid ShipmentStatus Tests
  describe "invalid shipment status" do
    it "is invalid without a name" do
      shipment_status.name = nil
      expect(shipment_status).not_to be_valid
    end

    it "is invalid with a blank name" do
      shipment_status.name = ""
      expect(shipment_status).not_to be_valid
    end
  end

  ## Dependent Nullify Tests
  describe "dependent nullify" do
    let!(:shipment) { create(:shipment, shipment_status_id: shipment_status.id, company: company) }

    it "does not destroy associated shipments when destroyed" do
      expect { shipment_status.destroy }.to change(Shipment, :count).by(0)
    end

    it "nullifies the column in the shipment" do
      shipment_status.destroy
      shipment.reload
      expect(shipment.shipment_status_id).to be_nil
    end
  end

  ## Edge Case Tests
  describe "edge cases" do
    it "is valid with a very long name" do
      long_name = "A" * 255 # Assuming a database or application limit of 255 characters
      shipment_status.name = long_name
      expect(shipment_status).to be_valid
    end

    it "is invalid with a name that is excessively long" do
      long_name = "A" * 256 # Assuming a limit of 255 characters
      shipment_status.name = long_name
      expect(shipment_status).not_to be_valid
    end
  end
end
