require 'rails_helper'

RSpec.describe "/deliveries", type: :request do
  let(:valid_user) { User.create!(email: "test@example.com", password: "password") }
  let!(:shipment_status) { ShipmentStatus.create!(name: "Pending") }


  let!(:unassigned_shipment) {
    Shipment.create!(
      name: "Unassigned Shipment",
      user_id: nil,
      sender_name: "John Doe",
      sender_address: "123 Sender St, Sender City",
      receiver_name: "Jane Smith",
      receiver_address: "456 Receiver Ave, Receiver City",
      weight: 50.0,
      boxes: 5,
      shipment_status_id: shipment_status.id
    )
  }

  let!(:assigned_shipment) {
    Shipment.create!(
      name: "Assigned Shipment",
      user: valid_user,
      sender_name: "John Doe",
      sender_address: "123 Sender St, Sender City",
      receiver_name: "Jane Smith",
      receiver_address: "456 Receiver Ave, Receiver City",
      weight: 75.0,
      boxes: 8,
      shipment_status_id: shipment_status.id
    )
  }

  before do
    sign_in valid_user, scope: :user
  end

  describe "GET /index" do
    it "renders a successful response" do
      get deliveries_url
      expect(response).to be_successful
    end

    it "assigns unassigned shipments to @unassigned_shipments" do
      get deliveries_url
      expect(assigns(:unassigned_shipments)).to include(unassigned_shipment)
      expect(assigns(:unassigned_shipments)).not_to include(assigned_shipment)
    end

    it "assigns current_user's shipments to @my_shipments" do
      get deliveries_url
      expect(assigns(:my_shipments)).to include(assigned_shipment)
      expect(assigns(:my_shipments)).not_to include(unassigned_shipment)
    end

    it "renders the correct template" do
      get deliveries_url
      expect(response).to render_template(:index)
    end
  end
end
