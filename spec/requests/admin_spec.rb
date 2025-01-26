require 'rails_helper'

RSpec.describe "/admin", type: :request do
  let(:company) { create(:company) }

  let(:admin_user) { create(:user, :admin, company: company) }
  let(:non_admin_user) { create(:user, company: company) }

  let!(:driver) { create(:user, :driver, company: company) }
  let!(:other_driver) { create(:user, :driver, company: create(:company)) }

  let!(:shipment_status) { create(:shipment_status, company: company) }
  let!(:other_shipment_status) { create(:shipment_status, company: create(:company)) }

  let!(:truck) { create(:truck, company: company) }
  let!(:other_truck) { create(:truck, company: create(:company)) }

  before do
    sign_in admin_user, scope: :user
  end

  describe "GET /index" do
    context "when the user is an admin" do
      it "renders a successful response" do
        get admin_index_url
        expect(response).to be_successful
      end

      it "assigns drivers from the current company to @drivers" do
        get admin_index_url
        expect(assigns(:drivers)).to include(driver)
        expect(assigns(:drivers)).not_to include(other_driver)
      end

      it "assigns shipment statuses from the current company to @shipment_statuses" do
        get admin_index_url
        expect(assigns(:shipment_statuses)).to include(shipment_status)
        expect(assigns(:shipment_statuses)).not_to include(other_shipment_status)
      end

      it "assigns trucks from the current company to @trucks" do
        get admin_index_url
        expect(assigns(:trucks)).to include(truck)
        expect(assigns(:trucks)).not_to include(other_truck)
      end

      it "renders the correct template" do
        get admin_index_url
        expect(response).to render_template(:index)
      end

      it "returns a successfull response" do
        get admin_index_url
        expect(response).to be_successful
      end
    end

    context "when the user is not an admin" do
      before do
        sign_out admin_user
        sign_in non_admin_user, scope: :user
      end

      it "redirects to the root path with an error message" do
        get admin_index_url
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end
  end
end
