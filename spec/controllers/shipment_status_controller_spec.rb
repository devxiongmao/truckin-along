require 'rails_helper'

RSpec.describe ShipmentStatusesController, type: :controller do
  let(:valid_user) { create(:user) }
  let!(:shipment_status) { create(:shipment_status) }

  before do
    sign_in valid_user, scope: :user
  end

  describe 'GET #index' do
    it 'assigns all shipment statuses to @shipment_statuses and renders the index template' do
      get :index
      expect(assigns(:shipment_statuses)).to eq([ shipment_status ])
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested shipment status to @shipment_status and renders the show template' do
      get :show, params: { id: shipment_status.id }
      expect(assigns(:shipment_status)).to eq(shipment_status)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new shipment status to @shipment_status and renders the new template' do
      get :new
      expect(assigns(:shipment_status)).to be_a_new(ShipmentStatus)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new shipment status and redirects to the show page' do
        expect {
          post :create, params: { shipment_status: { name: 'Shipped' } }
        }.to change(ShipmentStatus, :count).by(1)

        expect(response).to redirect_to(shipment_status_path(assigns(:shipment_status)))
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new shipment status and re-renders the new template' do
        expect {
          post :create, params: { shipment_status: { name: '' } }
        }.to_not change(ShipmentStatus, :count)

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested shipment status to @shipment_status and renders the edit template' do
      get :edit, params: { id: shipment_status.id }
      expect(assigns(:shipment_status)).to eq(shipment_status)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid attributes' do
      it 'updates the shipment status and redirects to the show page' do
        patch :update, params: { id: shipment_status.id, shipment_status: { name: 'Delivered' } }
        shipment_status.reload
        expect(shipment_status.name).to eq('Delivered')
        expect(response).to redirect_to(shipment_status_path(shipment_status))
      end
    end

    context 'with invalid attributes' do
      it 'does not update the shipment status and re-renders the edit template' do
        patch :update, params: { id: shipment_status.id, shipment_status: { name: '' } }
        expect(shipment_status.reload.name).to eq('Ready')
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the shipment status and redirects to the index page' do
      expect {
        delete :destroy, params: { id: shipment_status.id }
      }.to change(ShipmentStatus, :count).by(-1)

      expect(response).to redirect_to(shipment_statuses_path)
    end
  end
end
