require 'rails_helper'

RSpec.describe "/shipment_statuses", type: :request do
  let(:company) { create(:company) } # Create a company
  let(:user) { create(:user, company: company) } # Create a user tied to the company
  let(:other_company) { create(:company) } # Another company for isolation testing

  let!(:shipment_status) { create(:shipment_status, company: company) } # A status belonging to the current company
  let!(:other_shipment_status) { create(:shipment_status, company: other_company) } # A status from another company

  let(:valid_attributes) do
    {
      name: "In Transit",
      company_id: company.id
    }
  end

  let(:invalid_attributes) do
    {
      name: nil
    }
  end

  before do
    sign_in user, scope: :user
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_shipment_status_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response for a status from the current company" do
      get edit_shipment_status_url(shipment_status)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new ShipmentStatus for the current company" do
        expect {
          post shipment_statuses_url, params: { shipment_status: valid_attributes }
        }.to change(ShipmentStatus, :count).by(1)
        created_status = ShipmentStatus.last
        expect(created_status.company).to eq(company)
      end

      it "redirects to the admin index" do
        post shipment_statuses_url, params: { shipment_status: valid_attributes }
        expect(response).to redirect_to(admin_index_url)
      end
    end

    context "with invalid parameters" do
      it "does not create a new ShipmentStatus" do
        expect {
          post shipment_statuses_url, params: { shipment_status: invalid_attributes }
        }.to change(ShipmentStatus, :count).by(0)
      end

      it "renders an unprocessable_entity response" do
        post shipment_statuses_url, params: { shipment_status: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) do
      {
        name: "Delivered"
      }
    end

    context "with valid parameters" do
      it "updates the requested shipment status" do
        patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
        shipment_status.reload
        expect(shipment_status.name).to eq("Delivered")
      end

      it "redirects to the admin index" do
        patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
        expect(response).to redirect_to(admin_index_url)
      end
    end

    context "with invalid parameters" do
      it "does not update the shipment status" do
        patch shipment_status_url(shipment_status), params: { shipment_status: invalid_attributes }
        shipment_status.reload
        expect(shipment_status.name).not_to eq(nil)
      end

      it "renders an unprocessable_entity response" do
        patch shipment_status_url(shipment_status), params: { shipment_status: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested shipment status" do
      expect {
        delete shipment_status_url(shipment_status)
      }.to change(ShipmentStatus, :count).by(-1)
    end

    it "redirects to the admin index" do
      delete shipment_status_url(shipment_status)
      expect(response).to redirect_to(admin_index_url)
    end
  end
end
