require 'rails_helper'

RSpec.describe "/trucks", type: :request do
  let(:valid_user) { create(:user) }

  let(:valid_attributes) {
    {
      make: "Volvo",
      model: "VNL",
      year: 2021,
      mileage: 120000
    }
  }

  let(:invalid_attributes) {
    {
      make: nil,        # Missing required field
      model: nil,       # Missing required field
      year: 1800,       # Invalid year
      mileage: -1000    # Invalid mileage
    }
  }

  before do
    sign_in valid_user, scope: :user
  end

  describe "GET /index" do
    it "renders a successful response" do
      Truck.create! valid_attributes
      get trucks_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      truck = Truck.create! valid_attributes
      get truck_url(truck)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_truck_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      truck = Truck.create! valid_attributes
      get edit_truck_url(truck)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Truck" do
        expect {
          post trucks_url, params: { truck: valid_attributes }
        }.to change(Truck, :count).by(1)
      end

      it "redirects to the created truck" do
        post trucks_url, params: { truck: valid_attributes }
        expect(response).to redirect_to(truck_url(Truck.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Truck" do
        expect {
          post trucks_url, params: { truck: invalid_attributes }
        }.to change(Truck, :count).by(0)
      end

      it "renders a response with 422 status (i.e., to display the 'new' template)" do
        post trucks_url, params: { truck: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) {
      {
        make: "Updated Make",
        model: "Updated Model",
        year: 2022,
        mileage: 90000
      }
    }

    context "with valid parameters" do
      it "updates the requested truck" do
        truck = Truck.create! valid_attributes
        patch truck_url(truck), params: { truck: new_attributes }
        truck.reload
        expect(truck.make).to eq("Updated Make")
        expect(truck.model).to eq("Updated Model")
        expect(truck.year).to eq(2022)
        expect(truck.mileage).to eq(90000)
      end

      it "redirects to the truck" do
        truck = Truck.create! valid_attributes
        patch truck_url(truck), params: { truck: new_attributes }
        truck.reload
        expect(response).to redirect_to(truck_url(truck))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e., to display the 'edit' template)" do
        truck = Truck.create! valid_attributes
        patch truck_url(truck), params: { truck: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested truck" do
      truck = Truck.create! valid_attributes
      expect {
        delete truck_url(truck)
      }.to change(Truck, :count).by(-1)
    end

    it "redirects to the trucks list" do
      truck = Truck.create! valid_attributes
      delete truck_url(truck)
      expect(response).to redirect_to(trucks_url)
    end
  end
end
