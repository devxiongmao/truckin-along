require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  let(:company) { create(:company) } # Current company
  let(:valid_user) { create(:user, company: company) } # Logged-in user
  let(:other_company) { create(:company) } # A different company for isolation testing
  let!(:shipment_status) { create(:shipment_status, company: company) }
  let!(:shipment) { create(:shipment, company: company) }
  let!(:other_shipment) { create(:shipment, company: other_company) }

  let(:valid_attributes) do
    {
      name: "New Shipment",
      shipment_status_id: shipment_status.id,
      sender_name: "Sender",
      sender_address: "123 Street",
      receiver_name: "Receiver",
      receiver_address: "456 Avenue",
      weight: 50.0,
      boxes: 5,
      company_id: company.id
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      status: nil,
      status_id: nil,
      sender_name: nil,
      sender_address: nil,
      receiver_name: nil,
      receiver_address: nil,
      weight: nil,
      boxes: nil,
      company_id: company.id
    }
  end

  before do
    sign_in valid_user, scope: :user
  end

  describe 'GET #index' do
    it "assigns @shipments to shipments from the current company" do
      shipment # Trigger creation of the truck
      other_shipment # Trigger creation of a truck from another company

      get :index
      expect(assigns(:shipments)).to include(shipment)
      expect(assigns(:shipments)).not_to include(other_shipment)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "responds successfully" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested shipment to @shipment' do
      get :show, params: { id: shipment.id }
      expect(assigns(:shipment)).to eq(shipment)
    end

    it "renders the show template" do
      get :show, params: { id: shipment.id }
      expect(response).to render_template(:show)
    end

    it "responds successfully" do
      get :show, params: { id: shipment.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    it "assigns a new shipment as @shipment" do
      get :new
      expect(assigns(:shipment)).to be_a_new(Shipment)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end

    it "responds successfully" do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #edit" do
    it "assigns the requested shipment as @shipment" do
      get :edit, params: { id: shipment.id }
      expect(assigns(:shipment)).to eq(shipment)
    end

    it "renders the edit template" do
      get :edit, params: { id: shipment.id }
      expect(response).to render_template(:edit)
    end

    it "raises ActiveRecord::RecordNotFound for a shipments from another company" do
      expect {
        get :edit, params: { id: other_shipment.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "responds successfully" do
      get :edit, params: { id: shipment.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it 'creates a new shipment=' do
        expect {
          post :create, params: { shipment: valid_attributes }
        }.to change(Shipment, :count).by(1)
      end

      it 'creates a new shipment and redirects to the show page' do
        post :create, params: { shipment: valid_attributes }
        expect(response).to redirect_to(shipment_path(assigns(:shipment)))
      end
    end

    context "with invalid parameters" do
      it "does not create a new shipment" do
        expect {
          post :create, params: { shipment: invalid_attributes }
        }.to change(Shipment, :count).by(0)
      end

      it "renders the new template with unprocessable_entity status" do
        post :create, params: { shipment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    let(:new_attributes) do
      {
        name: "Delivered"
      }
    end

    context "with valid parameters" do
      it "updates the requested shipment" do
        patch :update, params: { id: shipment.id, shipment: new_attributes }
        shipment.reload
        expect(shipment.name).to eq("Delivered")
      end

      it "redirects to the shipments index path" do
        patch :update, params: { id: shipment.id, shipment: new_attributes }
        expect(response).to redirect_to(shipment_path(shipment))
      end
    end

    context "with invalid parameters" do
      it "does not update the shipment" do
        patch :update, params: { id: shipment.id, shipment: invalid_attributes }
        shipment.reload
        expect(shipment.name).not_to eq(nil)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch :update, params: { id: shipment.id, shipment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end

      it 'does not update the shipment and re-renders the edit template' do
        patch :update, params: { id: shipment.id, shipment: { name: '' } }
        expect(shipment.reload.name).to eq('Test Shipment')
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested shipment" do
      shipment
      expect {
        delete :destroy, params: { id: shipment.id }
      }.to change(Shipment, :count).by(-1)
    end

    it "redirects to the shipments list" do
      delete :destroy, params: { id: shipment.id }
      expect(response).to redirect_to(shipments_path)
    end

    it "raises ActiveRecord::RecordNotFound for a shipment_status from another company" do
      expect {
        delete :destroy, params: { id: other_shipment.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "POST #assign" do
    let!(:unassigned_shipment) { create(:shipment, user: nil, company: company) }
    let!(:unassigned_shipment2) { create(:shipment, user: nil, company: company) }

    let!(:unassigned_shipments) { [ unassigned_shipment, unassigned_shipment2 ] }

    it "assigns selected shipments to the current user" do
      shipment_ids = unassigned_shipments.map(&:id)
      post :assign, params: { shipment_ids: shipment_ids }

      unassigned_shipments.each do |shipment|
        shipment.reload
        expect(shipment.user_id).to eq(valid_user.id)
      end
    end

    it "redirects to the deliveries path" do
      post :assign, params: { shipment_ids: [] }
      expect(response).to redirect_to(deliveries_path)
    end

    it "shows an alert saying shipments have been assigned" do
      shipment_ids = unassigned_shipments.map(&:id)
      post :assign, params: { shipment_ids: shipment_ids }
      expect(flash[:notice]).to eq("Selected shipments have been assigned to you.")
    end

    it "shows an alert if no shipments are selected" do
      post :assign, params: { shipment_ids: [] }

      expect(flash[:alert]).to eq("No shipments were selected.")
    end
  end
end
