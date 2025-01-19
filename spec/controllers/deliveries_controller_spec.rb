require 'rails_helper'

RSpec.describe DeliveriesController, type: :controller do
  let(:company) { create(:company) } # Current company
  let(:other_company) { create(:company) } # A different company for isolation testing

  let(:valid_user) { create(:user, :driver, company: company) }
  let(:other_valid_user) { create(:user, :driver, company: other_company) }

  let!(:unassigned_shipment) { create(:shipment, user: nil, company: company) }
  let!(:other_unassigned_shipment) { create(:shipment, user: nil, company: other_company) }

  let!(:assigned_shipment)  { create(:shipment, user: valid_user, company: company) }
  let!(:other_assigned_shipment)  { create(:shipment, user: valid_user, company: other_company) }


  before do
    sign_in valid_user, scope: :user
  end

  describe 'GET #index' do
    it "assigns unassigned shipments to @unassigned_shipments from the current company" do
      unassigned_shipment # Trigger creation of the truck
      other_unassigned_shipment # Trigger creation of a truck from another company

      get :index
      expect(assigns(:unassigned_shipments)).to include(unassigned_shipment)
      expect(assigns(:unassigned_shipments)).not_to include(other_unassigned_shipment)
    end

    it "assigns current_users shipments to @my_shipments from the current company" do
      assigned_shipment # Trigger creation of the truck
      other_assigned_shipment # Trigger creation of a truck from another company

      get :index
      expect(assigns(:my_shipments)).to include(assigned_shipment)
      expect(assigns(:my_shipments)).not_to include(other_assigned_shipment)
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

      it 'responds successfully' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
