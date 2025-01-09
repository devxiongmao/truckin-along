require 'rails_helper'

RSpec.describe "/shipment_statuses", type: :request do
  let(:valid_user) { User.create!(email: "test@example.com", password: "password") }

  let!(:shipment_status) { ShipmentStatus.create!(name: "Pending") }

  let(:valid_attributes) {
    { name: "In Transit" }
  }

  let(:invalid_attributes) {
    { name: nil } # Invalid because name is required
  }

  before do
    sign_in valid_user, scope: :user
  end

  describe "GET /index" do
    it "renders a successful response" do
      ShipmentStatus.create! valid_attributes
      get shipment_statuses_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      shipment_status = ShipmentStatus.create! valid_attributes
      get shipment_status_url(shipment_status)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_shipment_status_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      shipment_status = ShipmentStatus.create! valid_attributes
      get edit_shipment_status_url(shipment_status)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new ShipmentStatus" do
        expect {
          post shipment_statuses_url, params: { shipment_status: valid_attributes }
        }.to change(ShipmentStatus, :count).by(1)
      end

      it "redirects to the created shipment_status" do
        post shipment_statuses_url, params: { shipment_status: valid_attributes }
        expect(response).to redirect_to(shipment_status_url(ShipmentStatus.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new ShipmentStatus" do
        expect {
          post shipment_statuses_url, params: { shipment_status: invalid_attributes }
        }.to change(ShipmentStatus, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post shipment_statuses_url, params: { shipment_status: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) {
      { name: "Delivered" }
    }

    context "with valid parameters" do
      it "updates the requested shipment_status" do
        shipment_status = ShipmentStatus.create! valid_attributes
        patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
        shipment_status.reload
        expect(shipment_status.name).to eq("Delivered")
      end

      it "redirects to the shipment_status" do
        shipment_status = ShipmentStatus.create! valid_attributes
        patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
        shipment_status.reload
        expect(response).to redirect_to(shipment_status_url(shipment_status))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        shipment_status = ShipmentStatus.create! valid_attributes
        patch shipment_status_url(shipment_status), params: { shipment_status: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested shipment_status" do
      shipment_status = ShipmentStatus.create! valid_attributes
      expect {
        delete shipment_status_url(shipment_status)
      }.to change(ShipmentStatus, :count).by(-1)
    end

    it "redirects to the shipment_statuses list" do
      shipment_status = ShipmentStatus.create! valid_attributes
      delete shipment_status_url(shipment_status)
      expect(response).to redirect_to(shipment_statuses_url)
    end
  end
end
