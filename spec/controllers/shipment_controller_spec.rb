require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  let!(:shipment) { Shipment.create!(name: "Test Shipment", status: "Pending", sender_name: "John Doe", sender_address: "123 Sender St", receiver_name: "Jane Smith", receiver_address: "456 Receiver Ave", weight: 100.5, boxes: 10) }

  describe 'GET #index' do
    it 'assigns all shipments to @shipments and renders the index template' do
      get :index
      expect(assigns(:shipments)).to eq([shipment])
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested shipment to @shipment and renders the show template' do
      get :show, params: { id: shipment.id }
      expect(assigns(:shipment)).to eq(shipment)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new shipment to @shipment and renders the new template' do
      get :new
      expect(assigns(:shipment)).to be_a_new(Shipment)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new shipment and redirects to the show page' do
        expect {
          post :create, params: { shipment: { name: "New Shipment", status: "In Transit", sender_name: "Sender", sender_address: "123 Street", receiver_name: "Receiver", receiver_address: "456 Avenue", weight: 50.0, boxes: 5 } }
        }.to change(Shipment, :count).by(1)

        expect(response).to redirect_to(shipment_path(assigns(:shipment)))
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new shipment and re-renders the new template' do
        expect {
          post :create, params: { shipment: { name: "", status: "", weight: -10, boxes: -1 } }
        }.to_not change(Shipment, :count)

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid attributes' do
      it 'updates the shipment and redirects to the show page' do
        patch :update, params: { id: shipment.id, shipment: { status: "Delivered" } }
        shipment.reload
        expect(shipment.status).to eq("Delivered")
        expect(response).to redirect_to(shipment_path(shipment))
      end
    end

    context 'with invalid attributes' do
      it 'does not update the shipment and re-renders the edit template' do
        patch :update, params: { id: shipment.id, shipment: { name: "" } }
        expect(shipment.reload.name).to eq("Test Shipment")
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the shipment and redirects to index' do
      expect {
        delete :destroy, params: { id: shipment.id }
      }.to change(Shipment, :count).by(-1)

      expect(response).to redirect_to(shipments_path)
    end
  end
end
