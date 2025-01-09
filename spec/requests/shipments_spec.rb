require 'rails_helper'

RSpec.describe "/shipments", type: :request do
  let(:valid_user) { User.create!(email: "test@example.com", password: "password") }

  let!(:shipment_status) { ShipmentStatus.create!(name: "Pending") }

  let(:valid_attributes) {
    {
      name: "Test Shipment",
      shipment_status_id: shipment_status.id, # Use the associated ShipmentStatus
      sender_name: "John Doe",
      sender_address: "123 Sender St, Sender City",
      receiver_name: "Jane Smith",
      receiver_address: "456 Receiver Ave, Receiver City",
      weight: 100.5,
      boxes: 10
    }
  }

  let(:invalid_attributes) {
    {
      name: nil, # Missing required field
      shipment_status_id: nil, # Invalid because it should belong to a ShipmentStatus
      sender_name: nil,
      sender_address: nil,
      receiver_name: nil,
      receiver_address: nil,
      weight: -10, # Invalid value
      boxes: -1    # Invalid value
    }
  }

  before do
    sign_in valid_user, scope: :user
  end

  describe "GET /index" do
    it "renders a successful response" do
      Shipment.create! valid_attributes
      get shipments_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      shipment = Shipment.create! valid_attributes
      get shipment_url(shipment)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_shipment_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      shipment = Shipment.create! valid_attributes
      get edit_shipment_url(shipment)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Shipment" do
        expect {
          post shipments_url, params: { shipment: valid_attributes }
        }.to change(Shipment, :count).by(1)
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

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post shipments_url, params: { shipment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let!(:new_status) { ShipmentStatus.create!(name: "In Transit") }
    let(:new_attributes) {
      {
        name: "Updated Shipment",
        shipment_status_id: new_status.id,
        weight: 150.75,
        boxes: 20
      }
    }

    context "with valid parameters" do
      it "updates the requested shipment" do
        shipment = Shipment.create! valid_attributes
        patch shipment_url(shipment), params: { shipment: new_attributes }
        shipment.reload
        expect(shipment.name).to eq("Updated Shipment")
        expect(shipment.shipment_status.name).to eq("In Transit")
        expect(shipment.weight).to eq(150.75)
        expect(shipment.boxes).to eq(20)
      end

      it "redirects to the shipment" do
        shipment = Shipment.create! valid_attributes
        patch shipment_url(shipment), params: { shipment: new_attributes }
        shipment.reload
        expect(response).to redirect_to(shipment_url(shipment))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        shipment = Shipment.create! valid_attributes
        patch shipment_url(shipment), params: { shipment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested shipment" do
      shipment = Shipment.create! valid_attributes
      expect {
        delete shipment_url(shipment)
      }.to change(Shipment, :count).by(-1)
    end

    it "redirects to the shipments list" do
      shipment = Shipment.create! valid_attributes
      delete shipment_url(shipment)
      expect(response).to redirect_to(shipments_url)
    end
  end
end
