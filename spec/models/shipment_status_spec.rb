require 'rails_helper'

RSpec.describe ShipmentStatus, type: :model do
  ## Association Tests
  describe "associations" do
    it { is_expected.to have_many(:shipments).dependent(:destroy) }
  end

  ## Validation Tests
  describe "validations" do
    subject { ShipmentStatus.new(name: "Pending") } # Use a valid ShipmentStatus as the baseline for testing

    # Presence Validations
    it { is_expected.to validate_presence_of(:name) }
  end

  ## Valid ShipmentStatus Test
  describe "valid shipment status" do
    it "is valid with a name" do
      shipment_status = ShipmentStatus.new(name: "Shipped")
      expect(shipment_status).to be_valid
    end
  end

  ## Invalid ShipmentStatus Tests
  describe "invalid shipment status" do
    it "is invalid without a name" do
      shipment_status = ShipmentStatus.new(name: nil)
      expect(shipment_status).not_to be_valid
    end

    it "is invalid with a blank name" do
      shipment_status = ShipmentStatus.new(name: "")
      expect(shipment_status).not_to be_valid
    end
  end

  ## Dependent Destroy Tests
  describe "dependent destroy" do
    let!(:shipment_status) { ShipmentStatus.create!(name: "Pending") }
    let!(:shipment) { Shipment.create!(name: "Test Shipment", shipment_status: shipment_status, sender_name: "John Doe", sender_address: "123 Sender St", receiver_name: "Jane Smith", receiver_address: "456 Receiver Ave", weight: 100, boxes: 5) }

    it "destroys associated shipments when destroyed" do
      expect { shipment_status.destroy }.to change(Shipment, :count).by(-1)
    end
  end

  ## Edge Case Tests
  describe "edge cases" do
    it "is valid with a very long name" do
      long_name = "A" * 255 # Assuming a database or application limit of 255 characters
      shipment_status = ShipmentStatus.new(name: long_name)
      expect(shipment_status).to be_valid
    end

    it "is invalid with a name that is excessively long" do
      long_name = "A" * 256 # Assuming a limit of 255 characters
      shipment_status = ShipmentStatus.new(name: long_name)
      expect(shipment_status).not_to be_valid
    end
  end
end
