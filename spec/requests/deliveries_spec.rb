require 'rails_helper'

RSpec.describe "/deliveries", type: :request do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }

  let(:valid_user) { create(:user, company: company) }

  let!(:unassigned_shipment) { create(:shipment, company: nil) }
  let!(:assigned_shipment) { create(:shipment, company: company, truck: nil) }

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

    it "renders the correct template" do
      get deliveries_url
      expect(response).to render_template(:index)
    end

    context 'when no shipments exist' do
      before do
        Shipment.destroy_all
      end

      it "shows the correct data for my shipments" do
        get deliveries_url
        expect(response.body).to include("You have no shipments assigned to you.")
      end

      it "shows the correct data for unassigned shipments" do
        get deliveries_url
        expect(response.body).to include("No unassigned shipments available.")
      end

      it "renders the correct template" do
        get deliveries_url
        expect(response).to render_template(:index)
      end

      it 'responds successfully' do
        get deliveries_url
        expect(response).to be_successful
      end
    end
  end

  describe "GET /truck_loading" do
    it "renders a successful response" do
      get truck_loading_deliveries_url
      expect(response).to be_successful
    end

    it "assigns current companies shipments that don't have a truck to @unassigned_shipments" do
      get truck_loading_deliveries_url
      expect(response.body).to include(assigned_shipment.name)
      expect(response.body).not_to include(unassigned_shipment.name)
    end

    it "assigns current companies trucks to @trucks" do
      get truck_loading_deliveries_url
      expect(response.body).to include(truck.make)
      expect(response.body).not_to include(other_truck.make)
    end

    it "renders the correct template" do
      get truck_loading_deliveries_url
      expect(response).to render_template(:truck_loading)
    end



    context 'when no shipments exist' do
      before do
        Shipment.destroy_all
      end

      it "shows the correct data for shipments" do
        get truck_loading_deliveries_url
        expect(response.body).to include("No unassigned shipments available.")
      end

      it "renders the correct template" do
        get truck_loading_deliveries_url
        expect(response).to render_template(:truck_loading)
      end

      it 'responds successfully' do
        get truck_loading_deliveries_url
        expect(response).to be_successful
      end
    end
  end

  describe "GET /start_delivery" do
    it "renders a successful response" do
      get start_delivery_deliveries_url
      expect(response).to be_successful
    end

    it "assigns current companies trucks to @trucks" do
      get start_delivery_deliveries_url
      expect(response.body).to include(truck.make)
      expect(response.body).not_to include(other_truck.make)
    end

    it "renders the correct template" do
      get start_delivery_deliveries_url
      expect(response).to render_template(:start_delivery)
    end

    context 'when no trucks exist' do
      before do
        Truck.destroy_all
      end

      it "shows the correct data for trucks" do
        get start_delivery_deliveries_url
        expect(response.body).to include("You don't have any trucks.")
      end

      it "renders the correct template" do
        get start_delivery_deliveries_url
        expect(response).to render_template(:start_delivery)
      end

      it 'responds successfully' do
        get start_delivery_deliveries_url
        expect(response).to be_successful
      end
    end
  end
end
