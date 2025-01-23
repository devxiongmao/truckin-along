require 'rails_helper'

RSpec.describe "/shipments", type: :request do
  let(:company) { create(:company) } # Create a company
  let(:user) { create(:user, company: company) } # Create a user tied to the company
  let(:other_company) { create(:company) } # Another company for isolation testing

  let!(:shipment) { create(:shipment, company: company) } # A shipment belonging to the current company
  let!(:other_shipment) { create(:shipment, company: other_company) } # A shipment from another company

  let!(:truck) { create(:truck, company: company) }
  let!(:status) { create(:shipment_status, company: company) }

  let(:valid_attributes) do
    {
      name: "Test Shipment",
      shipment_status_id: status.id,
      sender_name: "John Doe",
      sender_address: "123 Sender St",
      receiver_name: "Jane Smith",
      receiver_address: "456 Receiver Ave",
      weight: 100.5,
      length: 50.0,
      width: 20.0,
      height: 22.5,
      boxes: 10,
      truck_id: truck.id,
      user_id: user.id,
      company_id: company.id
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      shipment_status_id: status.id,
      sender_name: nil,
      sender_address: nil
    }
  end

  before do
    sign_in user, scope: :user
  end

  describe "GET /index" do
    it "renders a successful response with shipments from the current company" do
      get shipments_url
      expect(response).to be_successful
      expect(assigns(:shipments)).to include(shipment)
      expect(assigns(:shipments)).not_to include(other_shipment)
    end
  end

  describe "GET /show" do
    it "renders a successful response for a shipment from the current company" do
      get shipment_url(shipment)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_shipment_url
      expect(response).to be_successful
      expect(assigns(:drivers)).to include(user) # Ensure company resources are loaded
      expect(assigns(:trucks)).to include(truck)
      expect(assigns(:statuses)).to include(status)
    end
  end

  describe "GET /edit" do
    it "renders a successful response for a shipment from the current company" do
      get edit_shipment_url(shipment)
      expect(response).to be_successful
      expect(assigns(:drivers)).to include(user) # Ensure company resources are loaded
      expect(assigns(:trucks)).to include(truck)
      expect(assigns(:statuses)).to include(status)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Shipment for the current company" do
        expect {
          post shipments_url, params: { shipment: valid_attributes }
        }.to change(Shipment, :count).by(1)
        created_shipment = Shipment.last
        expect(created_shipment.company).to eq(company)
      end

      it "redirects to the created shipment" do
        post shipments_url, params: { shipment: valid_attributes }
        expect(response).to redirect_to(shipment_url(Shipment.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Shipment" do
        expect {
          post shipments_url, params: { shipment: invalid_attributes }
        }.to change(Shipment, :count).by(0)
      end

      it "renders an unprocessable_entity response" do
        post shipments_url, params: { shipment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) do
      {
        name: "Updated Shipment Name",
        weight: 200.0
      }
    end

    context "with valid parameters" do
      it "updates the requested shipment" do
        patch shipment_url(shipment), params: { shipment: new_attributes }
        shipment.reload
        expect(shipment.name).to eq("Updated Shipment Name")
        expect(shipment.weight).to eq(200.0)
      end

      it "redirects to the shipment" do
        patch shipment_url(shipment), params: { shipment: new_attributes }
        expect(response).to redirect_to(shipment_url(shipment))
      end
    end

    context "with invalid parameters" do
      it "does not update the shipment" do
        patch shipment_url(shipment), params: { shipment: invalid_attributes }
        shipment.reload
        expect(shipment.name).not_to eq(nil)
      end

      it "renders an unprocessable_entity response" do
        patch shipment_url(shipment), params: { shipment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested shipment" do
      expect {
        delete shipment_url(shipment)
      }.to change(Shipment, :count).by(-1)
    end

    it "redirects to the shipments list" do
      delete shipment_url(shipment)
      expect(response).to redirect_to(shipments_url)
    end
  end
end
