require 'rails_helper'

RSpec.describe ShipmentStatusesController, type: :controller do
  let(:company) { create(:company) } # Current company
  let(:valid_user) { create(:user, company: company) } # Logged-in user
  let(:other_company) { create(:company) } # A different company for isolation testing
  let!(:shipment_status) { create(:shipment_status, company: company) }
  let!(:other_shipment_status) { create(:shipment_status, company: other_company) }

  let(:valid_attributes) do
    {
      name: "Pending",
      company_id: company.id
    }
  end

  let(:invalid_attributes) do
    {
      name: nil
    }
  end

  before do
    sign_in valid_user, scope: :user
  end

  describe "GET #index" do
    it "assigns @shipment_statuses to shipment_statuses from the current company" do
      shipment_status # Trigger creation of the truck
      other_shipment_status # Trigger creation of a truck from another company

      get :index
      expect(assigns(:shipment_statuses)).to include(shipment_status)
      expect(assigns(:shipment_statuses)).not_to include(other_shipment_status)
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

  describe "GET #new" do
    it "assigns a new shipment_statuses as @shipment_statuses" do
      get :new
      expect(assigns(:shipment_status)).to be_a_new(ShipmentStatus)
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
    it "assigns the requested shipment_status as @shipment_status" do
      get :edit, params: { id: shipment_status.id }
      expect(assigns(:shipment_status)).to eq(shipment_status)
    end

    it "renders the edit template" do
      get :edit, params: { id: shipment_status.id }
      expect(response).to render_template(:edit)
    end

    it "raises ActiveRecord::RecordNotFound for a shipment_statuses from another company" do
      expect {
        get :edit, params: { id: other_shipment_status.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "responds successfully" do
      get :edit, params: { id: shipment_status.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new shipment_status for the current company" do
        expect {
          post :create, params: { shipment_status: valid_attributes }
        }.to change(ShipmentStatus, :count).by(1)
      end

      it "redirects to the created shipment_status" do
        post :create, params: { shipment_status: valid_attributes }
        expect(response).to redirect_to(shipment_statuses_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new shipment_status" do
        expect {
          post :create, params: { shipment_status: invalid_attributes }
        }.to change(ShipmentStatus, :count).by(0)
      end

      it "renders the new template with unprocessable_entity status" do
        post :create, params: { shipment_status: invalid_attributes }
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
      it "updates the requested shipment_status" do
        patch :update, params: { id: shipment_status.id, shipment_status: new_attributes }
        shipment_status.reload
        expect(shipment_status.name).to eq("Delivered")
      end

      it "redirects to the shipment_status index path" do
        patch :update, params: { id: shipment_status.id, shipment_status: new_attributes }
        expect(response).to redirect_to(shipment_statuses_path)
      end
    end

    context "with invalid parameters" do
      it "does not update the shipment_status" do
        patch :update, params: { id: shipment_status.id, shipment_status: invalid_attributes }
        shipment_status.reload
        expect(shipment_status.name).not_to eq(nil)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch :update, params: { id: shipment_status.id, shipment_status: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end

      it 'does not update the shipment status and re-renders the edit template' do
        patch :update, params: { id: shipment_status.id, shipment_status: { name: '' } }
        expect(shipment_status.reload.name).to eq('Ready')
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested shipment_status" do
      shipment_status
      expect {
        delete :destroy, params: { id: shipment_status.id }
      }.to change(ShipmentStatus, :count).by(-1)
    end

    it "redirects to the shipment_statuses list" do
      delete :destroy, params: { id: shipment_status.id }
      expect(response).to redirect_to(shipment_statuses_path)
    end

    it "raises ActiveRecord::RecordNotFound for a shipment_status from another company" do
      expect {
        delete :destroy, params: { id: other_shipment_status.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
