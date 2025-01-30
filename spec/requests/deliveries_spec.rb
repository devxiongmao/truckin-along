require 'rails_helper'

RSpec.describe "/deliveries", type: :request do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }

  let(:valid_user) { create(:user, company: company) }

  let!(:unassigned_shipment) { create(:shipment, user: nil, company: company, truck: nil) }
  let!(:assigned_shipment) { create(:shipment, user: valid_user, company: company) }

  let!(:truck) { create(:truck, company: company) }
  let!(:other_truck) { create(:truck, company: other_company) }

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

  describe "GET /truck_loading" do
    it "renders a successful response" do
      get truck_loading_deliveries_url
      expect(response).to be_successful
    end

    it "assigns unassigned shipments to @unassigned_shipments" do
      get truck_loading_deliveries_url
      expect(assigns(:unassigned_shipments)).to include(unassigned_shipment)
      expect(assigns(:unassigned_shipments)).not_to include(assigned_shipment)
    end

    it "assigns current companies trucks to @trucks" do
      get truck_loading_deliveries_url
      expect(assigns(:trucks)).to include(truck)
      expect(assigns(:trucks)).not_to include(other_truck)
    end

    it "renders the correct template" do
      get truck_loading_deliveries_url
      expect(response).to render_template(:truck_loading)
    end
  end
end
