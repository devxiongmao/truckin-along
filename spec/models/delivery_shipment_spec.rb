require 'rails_helper'

RSpec.describe DeliveryShipment, type: :model do
  # Define a valid delivery_shipment object for reuse
  let(:valid_delivery) { create(:delivery_shipment) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to belong_to(:shipment) }
    it { is_expected.to belong_to(:delivery) }
  end
end
