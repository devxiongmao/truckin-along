require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  let(:company) { create(:company) } # Current company
  let(:other_company) { create(:company) } # A different company for isolation testing

  let(:admin_user) { create(:user, :admin, company: company) }
  let(:non_admin_user) { create(:user, company: company) }

  let!(:driver) { create(:user, :driver, company: company) }
  let!(:other_driver) { create(:user, :driver, company: other_company) }

  let!(:shipment_status) { create(:shipment_status, company: company) }
  let!(:other_shipment_status) { create(:shipment_status, company: other_company) }

  let(:truck) { create(:truck, company: company) }
  let(:other_truck) { create(:truck, company: other_company) }

  before do
    sign_in admin_user, scope: :user
  end

  describe 'GET #index' do
    context 'when the user is an admin' do
      it 'assigns drivers from the current company to @drivers' do
        get :index
        expect(assigns(:drivers)).to include(driver)
        expect(assigns(:drivers)).not_to include(other_driver)
      end

      it 'assigns shipment statuses from the current company to @shipment_statuses' do
        get :index
        expect(assigns(:shipment_statuses)).to include(shipment_status)
        expect(assigns(:shipment_statuses)).not_to include(other_shipment_status)
      end

      it "assigns @trucks to trucks from the current company" do
        get :index
        expect(assigns(:trucks)).to include(truck)
        expect(assigns(:trucks)).not_to include(other_truck)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it "responds successfully" do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the user is not an admin' do
      before do
        sign_out admin_user
        sign_in non_admin_user, scope: :user
      end

      it 'redirects to the root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it 'renders an error message' do
        get :index
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end
  end
end
