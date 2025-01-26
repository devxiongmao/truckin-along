require 'rails_helper'

RSpec.describe TrucksController, type: :controller do
  let(:company) { create(:company) } # Current company
  let(:user) { create(:user, :admin, company: company) } # Logged-in user
  let(:non_admin_user) { create(:user, company: company) } # Logged-in user

  let(:other_company) { create(:company) } # A different company for isolation testing
  let(:truck) { create(:truck, company: company) } # Truck belonging to the current company
  let(:other_truck) { create(:truck, company: other_company) } # Truck from another company

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

    describe "GET #show" do
      it "assigns the requested truck as @truck" do
        get :show, params: { id: truck.id }
        expect(assigns(:truck)).to eq(truck)
      end

      it "renders the show template" do
        get :show, params: { id: truck.id }
        expect(response).to render_template(:show)
      end

      it "responds successfully" do
        get :show, params: { id: truck.id }
        expect(response).to have_http_status(:ok)
      end

      it "raises ActiveRecord::RecordNotFound for a truck from another company" do
        expect {
          get :show, params: { id: other_truck.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "GET #new" do
      it "assigns a new truck as @truck" do
        get :new
        expect(assigns(:truck)).to be_a_new(Truck)
      end

      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end

      it "responds successfully" do
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET #edit" do
      it "assigns the requested truck as @truck" do
        get :edit, params: { id: truck.id }
        expect(assigns(:truck)).to eq(truck)
      end

      it "renders the edit template" do
        get :edit, params: { id: truck.id }
        expect(response).to render_template(:edit)
      end

      it "raises ActiveRecord::RecordNotFound for a truck from another company" do
        expect {
          get :edit, params: { id: other_truck.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "responds successfully" do
        get :edit, params: { id: truck.id }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST #create" do
      context "with valid parameters" do
        it "creates a new truck for the current company" do
          expect {
            post :create, params: { truck: valid_attributes }
          }.to change(Truck, :count).by(1)
        end

        it "redirects to the created truck" do
          post :create, params: { truck: valid_attributes }
          expect(response).to redirect_to(trucks_path)
        end
      end

      context "with invalid parameters" do
        it "does not create a new truck" do
          expect {
            post :create, params: { truck: invalid_attributes }
          }.to change(Truck, :count).by(0)
        end

        it "renders the new template with unprocessable_entity status" do
          post :create, params: { truck: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH #update" do
      let(:new_attributes) do
        {
          make: "Ford",
          model: "F-150",
          mileage: 15000
        }
      end

      context "with valid parameters" do
        it "updates the requested truck" do
          patch :update, params: { id: truck.id, truck: new_attributes }
          truck.reload
          expect(truck.make).to eq("Ford")
          expect(truck.model).to eq("F-150")
          expect(truck.mileage).to eq(15000)
        end

        it "redirects to the truck" do
          patch :update, params: { id: truck.id, truck: new_attributes }
          expect(response).to redirect_to(trucks_path)
        end
      end

      context "with invalid parameters" do
        it "does not update the truck" do
          patch :update, params: { id: truck.id, truck: invalid_attributes }
          truck.reload
          expect(truck.make).not_to eq(nil)
        end

        it "renders the edit template with unprocessable_entity status" do
          patch :update, params: { id: truck.id, truck: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
        end

        it 'does not update the truck and re-renders the edit template' do
          patch :update, params: { id: truck.id, truck: { make: '' } }
          expect(truck.reload.make).to eq('Volvo')
          expect(response).to render_template(:edit)
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested truck" do
        truck
        expect {
          delete :destroy, params: { id: truck.id }
        }.to change(Truck, :count).by(-1)
      end

      it "redirects to the admin index" do
        delete :destroy, params: { id: truck.id }
        expect(response).to redirect_to(admin_index_path)
      end

      it "raises ActiveRecord::RecordNotFound for a truck from another company" do
        expect {
          delete :destroy, params: { id: other_truck.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "when user is not an admin" do
    before do
      sign_in non_admin_user, scope: :user
    end

    describe "GET #show" do
      it 'redirects to the root path' do
        get :show, params: { id: truck.id }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        get :show, params: { id: truck.id }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe 'GET #new' do
      it 'redirects to the root path' do
        get :new
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        get :new
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe 'GET #edit' do
      it 'redirects to the root path' do
        get :edit, params: { id: truck.id }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        get :edit, params: { id: truck.id }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe 'POST #create' do
      it 'redirects to the root path' do
        post :create, params: { truck: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        post :create, params: { truck: valid_attributes }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe 'PATCH #update' do
      it 'redirects to the root path' do
        patch :update, params: { id: truck.id, truck: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        patch :update, params: { id: truck.id, truck: valid_attributes }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe "DELETE #destroy" do
      it 'redirects to the root path' do
        delete :destroy, params: { id: truck.id }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        delete :destroy, params: { id: truck.id }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end
  end
end
