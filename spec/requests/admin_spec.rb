require 'rails_helper'

RSpec.describe "/admin", type: :request do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }

  let(:admin_user) { create(:user, :admin, company: company) }
  let(:non_admin_user) { create(:user, company: company) }

  let!(:driver) { create(:user, :driver, company: company) }
  let!(:other_driver) { create(:user, :driver, company: other_company) }

  let!(:shipment_status) { create(:shipment_status, company: company) }
  let!(:other_shipment_status) { create(:shipment_status, company: other_company) }

  let!(:truck) { create(:truck, company: company) }
  let!(:other_truck) { create(:truck, company: other_company) }

  let!(:preference) { create(:shipment_action_preference, company: company, shipment_status: shipment_status, action: "loaded_onto_truck") }
  let!(:other_preference) { create(:shipment_action_preference, company: other_company, shipment_status: other_shipment_status) }

  describe "GET /admin" do
    context "when the user is an admin" do
      before do
        sign_in admin_user, scope: :user
      end

      it "includes only drivers from the admin's company" do
        get admin_index_path
        expect(response.body).to include(driver.email)
        expect(response.body).not_to include(other_driver.email)
      end

      it "includes only shipment statuses from the admin's company" do
        get admin_index_path
        expect(response.body).to include(shipment_status.name)
        expect(response.body).not_to include(other_shipment_status.name)
      end

      it "includes only trucks from the admin's company" do
        get admin_index_path
        expect(response.body).to include(truck.make)
        expect(response.body).not_to include(other_truck.make)
      end

      it "includes only shipment action preferences from the admin's company" do
        get admin_index_path
        expect(response.body).to include("Loaded onto truck")
        expect(response.body).not_to include("Claimed by company")
      end

      it "renders the index template" do
        get admin_index_path
        expect(response).to render_template(:index)
      end

      it "responds successfully" do
        get admin_index_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is not an admin" do
      before do
        sign_in non_admin_user
      end

      it "redirects to the dashboard path" do
        get admin_index_path
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders an error message" do
        get admin_index_path
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
