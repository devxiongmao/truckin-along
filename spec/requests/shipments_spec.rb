require 'rails_helper'

RSpec.describe "/shipments", type: :request do
  let(:valid_user) { create(:user, :customer) }
  let(:other_user) { create(:user, :customer) }

  let(:company) { create(:company) }

  let(:admin_user) { create(:user, :admin, company: company) }
  let(:shipment_status) { create(:shipment_status) }

  let!(:shipment) { create(:shipment, user: valid_user) }
  let!(:other_shipment) { create(:shipment, user: other_user) }

  let(:valid_attributes) do
    {
      name: "Test Shipment",
      shipment_status_id: status.id,
      sender_name: "John Doe",
      sender_address: "123 Sender St",
      receiver_name: "Jane Smith",
      receiver_address: "456 Receiver Ave",
      weight: 100.5,
      length: 50.0,
      width: 20.0,
      height: 22.5,
      boxes: 10,
      truck_id: truck.id,
      user_id: user.id,
      company_id: company.id
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      shipment_status_id: status.id,
      sender_name: nil,
      sender_address: nil
    }
  end

  # TO BE REFACTORED
end
