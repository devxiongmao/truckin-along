require 'rails_helper'

RSpec.describe "/trucks", type: :request do
  let(:company) { create(:company) } # Create a company
  let(:user) { create(:user, :admin, company: company) } # Create a user tied to the company
  let(:non_admin_user) { create(:user, company: company) }

  let(:other_company) { create(:company) } # Another company for isolation testing

  let!(:truck) { create(:truck, company: company) } # A truck belonging to the current company
  let!(:other_truck) { create(:truck, company: other_company) } # A truck from another company

  let(:valid_attributes) do
    {
      make: "Toyota",
      model: "Tacoma",
      year: 2022,
      mileage: 12000,
      company_id: company.id,
      weight: 2000.0,
      length: 5050.0,
      width: 200.0,
      height: 220.5
    }
  end

  let(:invalid_attributes) do
    {
      make: nil,
      model: nil
    }
  end

  describe "when the user is an admin" do
    before do
      sign_in user, scope: :user
    end

    describe "GET /show" do
      it "renders a successful response for a truck from the current company" do
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
      it "renders a successful response for a truck from the current company" do
        get edit_truck_url(truck)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new Truck for the current company" do
          expect {
            post trucks_url, params: { truck: valid_attributes }
          }.to change(Truck, :count).by(1)
          created_truck = Truck.last
          expect(created_truck.company).to eq(company)
        end

        it "redirects to the created truck" do
          post trucks_url, params: { truck: valid_attributes }
          expect(response).to redirect_to(trucks_url)
        end
      end

      context "with invalid parameters" do
        it "does not create a new Truck" do
          expect {
            post trucks_url, params: { truck: invalid_attributes }
          }.to change(Truck, :count).by(0)
        end

        it "renders an unprocessable_entity response" do
          post trucks_url, params: { truck: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "PATCH /update" do
      let(:new_attributes) do
        {
          make: "Ford",
          model: "F-150",
          mileage: 20000
        }
      end

      context "with valid parameters" do
        it "updates the requested truck" do
          patch truck_url(truck), params: { truck: new_attributes }
          truck.reload
          expect(truck.make).to eq("Ford")
          expect(truck.model).to eq("F-150")
          expect(truck.mileage).to eq(20000)
        end

        it "redirects to the truck" do
          patch truck_url(truck), params: { truck: new_attributes }
          expect(response).to redirect_to(trucks_url)
        end
      end

      context "with invalid parameters" do
        it "does not update the truck" do
          patch truck_url(truck), params: { truck: invalid_attributes }
          truck.reload
          expect(truck.make).not_to eq(nil)
        end

        it "renders an unprocessable_entity response" do
          patch truck_url(truck), params: { truck: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested truck" do
        expect {
          delete truck_url(truck)
        }.to change(Truck, :count).by(-1)
      end

      it "redirects to the trucks list" do
        delete truck_url(truck)
        expect(response).to redirect_to(admin_index_url)
      end
    end
  end

  describe "when the user is not an admin" do
    before do
      sign_in non_admin_user, scope: :user
    end

    describe "GET /show" do
      it "redirects to the root path" do
        get truck_url(truck)
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        get truck_url(truck)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "GET /new" do
      it "redirects to the root path" do
        get new_truck_url
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        get new_truck_url
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "GET /edit" do
      it "redirects to the root path" do
        get truck_url(truck)
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        get truck_url(truck)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "POST /create" do
      it "redirects to the root path" do
        post trucks_url, params: { truck: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        post trucks_url, params: { truck: valid_attributes }
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "PATCH /update" do
      it "redirects to the root path" do
        patch truck_url(truck), params: { truck: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        patch truck_url(truck), params: { truck: valid_attributes }
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "DELETE /destroy" do
      it "redirects to the root path" do
        delete truck_url(truck)
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        delete truck_url(truck)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end
  end
end
