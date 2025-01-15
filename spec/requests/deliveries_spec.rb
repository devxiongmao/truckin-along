require 'rails_helper'

RSpec.describe "/deliveries", type: :request do
  let(:valid_user) { create(:user) }
  let!(:shipment_status) { create(:shipment_status) }

  let!(:unassigned_shipment) { create(:shipment, user: nil) }
  let!(:assigned_shipment) { create(:shipment, user: valid_user) }

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
end
