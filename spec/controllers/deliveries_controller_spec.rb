require 'rails_helper'

RSpec.describe DeliveriesController, type: :controller do
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

  describe 'GET #index' do
    it 'assigns unassigned shipments to @unassigned_shipments' do
      get :index
      expect(assigns(:unassigned_shipments)).to eq([ unassigned_shipment ])
    end

    it 'assigns current_users shipments to @my_shipments' do
      get :index
      expect(assigns(:my_shipments).pluck(:id)).to include(assigned_shipment.id)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    context 'when no shipments exist' do
      before do
        Shipment.destroy_all
      end

      it 'assigns an empty array to @unassigned_shipments and @my_shipments' do
        get :index
        expect(assigns(:unassigned_shipments)).to be_empty
        expect(assigns(:my_shipments)).to be_empty
      end

      it 'renders the index template successfully' do
        get :index
        expect(response).to render_template(:index)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
