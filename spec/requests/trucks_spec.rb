require 'rails_helper'

RSpec.describe "/trucks", type: :request do
  let(:company) { create(:company) }
  let(:admin_user) { create(:user, :admin, company: company) }
  let(:driver_user) { create(:user, :driver, company: company) }
  let(:customer_user) { create(:user, :customer, company: company) }

  let(:other_company) { create(:company) }
  let!(:truck) { create(:truck, company: company) }
  let!(:other_truck) { create(:truck, company: other_company) }

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
      height: 220.5,
      license_plate: "AXY-1234",
      vin: "WDBRF61J43F765432"
    }
  end

  let(:invalid_attributes) do
    {
      make: nil,
      model: nil
    }
  end

  let(:new_attributes) do
    {
      make: "Ford",
      model: "F-150",
      mileage: 20000
    }
  end

  let(:valid_form_attributes) do
    {
      title: "This is the title",
      last_inspection_date: "2025-03-29",
      mileage: 100232,
      oil_changed: true,
      tire_pressure_checked: true,
      additional_notes: "This is the notes"
    }
  end

  let(:invalid_form_attributes) do
    {
      # missing title
      last_inspection_date: "2025-03-29",
      mileage: 100232,
      oil_changed: true,
      tire_pressure_checked: true,
      additional_notes: "This is the notes"
    }
  end

  describe "when the user is an admin" do
    before do
      sign_in admin_user, scope: :user
    end

    describe "GET /show" do
      it "assigns the requested truck as @truck" do
        get truck_url(truck)
        expect(response.body).to include(truck.make)
        expect(response.body).to include(truck.model)
      end

      it "renders the show template" do
        get truck_url(truck)
        expect(response).to render_template(:show)
      end

      it "renders a successful response for a truck from the current company" do
        get truck_url(truck)
        expect(response).to be_successful
      end

      context "when the truck belongs to another company" do
        it 'redirects to the dashboard path' do
          get truck_url(other_truck)
          expect(response).to redirect_to(dashboard_path)
        end

        it 'renders with an alert' do
          get truck_url(other_truck)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end

    describe "GET /new" do
      it "displays a new form" do
        get new_truck_url
        expect(response.body).to include('form')
      end

      it "renders the new template" do
        get new_truck_url
        expect(response).to render_template(:new)
      end

      it "renders a successful response" do
        get new_truck_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "assigns the requested truck as @truck" do
        get edit_truck_url(truck)
        expect(response.body).to include(truck.make)
        expect(response.body).to include(truck.model)
      end

      it "renders the edit template" do
        get edit_truck_url(truck)
        expect(response).to render_template(:edit)
      end

      it "responds successfully" do
        get edit_truck_url(truck)
        expect(response).to be_successful
      end

      context "when the truck belongs to another company" do
        it 'redirects to the dashboard path' do
          get edit_truck_url(other_truck)
          expect(response).to redirect_to(dashboard_path)
        end

        it 'renders with an alert' do
          get edit_truck_url(other_truck)
          expect(flash[:alert]).to eq("Not authorized.")
        end
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

        it "redirects to the admin index path" do
          post trucks_url, params: { truck: valid_attributes }
          expect(response).to redirect_to(admin_index_url)
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

        it 're-renders the new template' do
          post trucks_url, params: { truck: invalid_attributes }
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        it "updates the requested truck" do
          patch truck_url(truck), params: { truck: new_attributes }
          truck.reload
          expect(truck.make).to eq("Ford")
          expect(truck.model).to eq("F-150")
          expect(truck.mileage).to eq(20000)
        end

        it "redirects to the admin index path" do
          patch truck_url(truck), params: { truck: new_attributes }
          expect(response).to redirect_to(admin_index_url)
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

        it 're-renders the edit template' do
          patch truck_url(truck), params: { truck: invalid_attributes }
          expect(response).to render_template(:edit)
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested truck" do
        expect {
          delete truck_url(truck)
        }.to change(Truck, :count).by(-1)
      end

      it "redirects to the admin index" do
        delete truck_url(truck)
        expect(response).to redirect_to(admin_index_url)
      end

      context "when the truck belongs to another company" do
        it 'redirects to the dashboard path' do
          delete truck_url(other_truck)
          expect(response).to redirect_to(dashboard_path)
        end

        it 'renders with an alert' do
          delete truck_url(other_truck)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end

    describe "POST /create_form" do
      let!(:truck) { create(:truck, company: company, active: false) }

      context "with valid parameters" do
        it "creates a new form" do
          expect {
            post create_form_truck_url(truck), params: valid_form_attributes
          }.to change(Form, :count).by(1)
        end

        it "updates the truck to active" do
          post create_form_truck_url(truck), params: valid_form_attributes
          truck.reload
          expect(truck.active).to be(true)
        end

        it "redirects to the dashboard path" do
          post create_form_truck_url(truck), params: valid_form_attributes
          expect(response).to redirect_to(dashboard_url)
        end

        it 'renders with the correct notice alert' do
          post create_form_truck_url(truck), params: valid_form_attributes
          expect(flash[:notice]).to eq("Maintenance form successfully submitted.")
        end
      end

      context "with invalid parameters" do
        it "does not create a new Form" do
          expect {
            post create_form_truck_url(truck), params: invalid_form_attributes
          }.to change(Form, :count).by(0)
        end

        it "does not update the truck to active" do
          post create_form_truck_url(truck), params: invalid_form_attributes
          truck.reload
          expect(truck.active).to be(false)
        end

        it "redirects to the dashboard path" do
          post create_form_truck_url(truck), params: invalid_form_attributes
          expect(response).to redirect_to(dashboard_url)
        end

        it 'renders with an alert' do
          post create_form_truck_url(truck), params: invalid_form_attributes
          expect(flash[:alert]).to eq("Unable to save form.")
        end
      end

      context "when the truck belongs to another company" do
        it 'redirects to the dashboard path' do
          post create_form_truck_url(other_truck), params: valid_form_attributes
          expect(response).to redirect_to(dashboard_path)
        end

        it 'renders with an alert' do
          post create_form_truck_url(other_truck), params: valid_form_attributes
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end
  end

  describe "when the user is a driver" do
    before do
      sign_in driver_user, scope: :user
    end

    describe "GET /show" do
      it "renders the show template" do
        get truck_url(truck)
        expect(response).to render_template(:show)
      end

      it "renders a successful response for a truck from the current company" do
        get truck_url(truck)
        expect(response).to be_successful
      end

      context "when the truck belongs to another company" do
        it 'redirects to the dashboard path' do
          get truck_url(other_truck)
          expect(response).to redirect_to(dashboard_path)
        end

        it 'renders with an alert' do
          get truck_url(other_truck)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end

    describe "GET /new" do
      it "redirects to the dashboard path" do
        get new_truck_url
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get new_truck_url
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET /edit" do
      it "redirects to the dashboard path" do
        get edit_truck_url(truck)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get edit_truck_url(truck)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST /create" do
      it "does not create the truck" do
        expect {
          post trucks_url, params: { truck: valid_attributes }
        }.not_to change(Truck, :count)
      end

      it "redirects to the dashboard path" do
        post trucks_url, params: { truck: valid_attributes }
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        post trucks_url, params: { truck: valid_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "PATCH /update" do
      it "does not update the truck" do
        patch truck_url(truck), params: { truck: new_attributes }
        truck.reload
        expect(truck.make).not_to eq("Ford")
      end

      it "redirects to the dashboard path" do
        patch truck_url(truck), params: { truck: new_attributes }
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        patch truck_url(truck), params: { truck: new_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "DELETE /destroy" do
      it "does not destroy the truck" do
        expect {
          delete truck_url(truck)
        }.not_to change(Truck, :count)
      end

      it "redirects to the dashboard path" do
        delete truck_url(truck)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        delete truck_url(truck)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST /create_form" do
      let!(:truck) { create(:truck, company: company, active: false) }

      context "with valid parameters" do
        it "creates a new form" do
          expect {
            post create_form_truck_url(truck), params: valid_form_attributes
          }.to change(Form, :count).by(1)
        end

        it "updates the truck to active" do
          post create_form_truck_url(truck), params: valid_form_attributes
          truck.reload
          expect(truck.active).to be(true)
        end

        it "redirects to the dashboard path" do
          post create_form_truck_url(truck), params: valid_form_attributes
          expect(response).to redirect_to(dashboard_url)
        end

        it 'renders with the correct notice alert' do
          post create_form_truck_url(truck), params: valid_form_attributes
          expect(flash[:notice]).to eq("Maintenance form successfully submitted.")
        end
      end

      context "with invalid parameters" do
        it "does not create a new Form" do
          expect {
            post create_form_truck_url(truck), params: invalid_form_attributes
          }.to change(Form, :count).by(0)
        end

        it "does not update the truck to active" do
          post create_form_truck_url(truck), params: invalid_form_attributes
          truck.reload
          expect(truck.active).to be(false)
        end

        it "redirects to the dashboard path" do
          post create_form_truck_url(truck), params: invalid_form_attributes
          expect(response).to redirect_to(dashboard_url)
        end

        it 'renders with an alert' do
          post create_form_truck_url(truck), params: invalid_form_attributes
          expect(flash[:alert]).to eq("Unable to save form.")
        end
      end

      context "when the truck belongs to another company" do
        it 'redirects to the dashboard path' do
          post create_form_truck_url(other_truck), params: valid_form_attributes
          expect(response).to redirect_to(dashboard_path)
        end

        it 'renders with an alert' do
          post create_form_truck_url(other_truck), params: valid_form_attributes
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end
  end

  describe "when the user is a customer" do
    before do
      sign_in customer_user, scope: :user
    end

    describe "GET /show" do
      it "redirects to the dashboard path" do
        get truck_url(truck)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get truck_url(truck)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET /new" do
      it "redirects to the dashboard path" do
        get new_truck_url
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get new_truck_url
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET /edit" do
      it "redirects to the dashboard path" do
        get edit_truck_url(truck)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get edit_truck_url(truck)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST /create" do
      it "does not create the truck" do
        expect {
          post trucks_url, params: { truck: valid_attributes }
        }.not_to change(Truck, :count)
      end

      it "redirects to the dashboard path" do
        post trucks_url, params: { truck: valid_attributes }
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        post trucks_url, params: { truck: valid_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "PATCH /update" do
      it "does not update the truck" do
        patch truck_url(truck), params: { truck: new_attributes }
        truck.reload
        expect(truck.make).not_to eq("Ford")
      end

      it "redirects to the dashboard path" do
        patch truck_url(truck), params: { truck: new_attributes }
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        patch truck_url(truck), params: { truck: new_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "DELETE /destroy" do
      it "does not destroy the truck" do
        expect {
          delete truck_url(truck)
        }.not_to change(Truck, :count)
      end

      it "redirects to the dashboard path" do
        delete truck_url(truck)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        delete truck_url(truck)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST /create_form" do
      let!(:truck) { create(:truck, company: company, active: false) }

      it "does not create a new form" do
        expect {
          post create_form_truck_url(truck), params: valid_form_attributes
        }.not_to change(Form, :count)
      end

      it "does not update the truck to active" do
        post create_form_truck_url(truck), params: valid_form_attributes
        truck.reload
        expect(truck.active).not_to eq(true)
      end

      it "redirects to the dashboard path" do
        post create_form_truck_url(truck), params: valid_form_attributes
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        post create_form_truck_url(truck), params: valid_form_attributes
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
