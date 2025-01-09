require 'rails_helper'

RSpec.describe TrucksController, type: :controller do
  let(:valid_user) { User.create!(email: "test@example.com", password: "password") }

  let!(:truck) { Truck.create(make: 'Ford', model: 'F-150', year: 2022, mileage: 15000) }

  before do
    sign_in valid_user, scope: :user
  end

  describe 'GET #index' do
    it 'assigns all trucks to @trucks and renders the index template' do
      get :index
      expect(assigns(:trucks)).to eq([ truck ])
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested truck to @truck and renders the show template' do
      get :show, params: { id: truck.id }
      expect(assigns(:truck)).to eq(truck)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new truck to @truck and renders the new template' do
      get :new
      expect(assigns(:truck)).to be_a_new(Truck)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested truck to @truck and renders the edit template' do
      get :edit, params: { id: truck.id }
      expect(assigns(:truck)).to eq(truck)
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new truck and redirects to the show page' do
        expect {
          post :create, params: { truck: { make: 'Chevy', model: 'Silverado', year: 2021, mileage: 10000 } }
        }.to change(Truck, :count).by(1)

        expect(response).to redirect_to(truck_path(assigns(:truck)))
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new truck and re-renders the new template' do
        expect {
          post :create, params: { truck: { make: '', model: '', year: 2021, mileage: 10000 } }
        }.to_not change(Truck, :count)

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid attributes' do
      it 'updates the truck and redirects to the show page' do
        patch :update, params: { id: truck.id, truck: { make: 'Dodge' } }
        truck.reload
        expect(truck.make).to eq('Dodge')
        expect(response).to redirect_to(truck_path(truck))
      end
    end

    context 'with invalid attributes' do
      it 'does not update the truck and re-renders the edit template' do
        patch :update, params: { id: truck.id, truck: { make: '' } }
        expect(truck.reload.make).to eq('Ford')
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the truck and redirects to index' do
      expect {
        delete :destroy, params: { id: truck.id }
      }.to change(Truck, :count).by(-1)

      expect(response).to redirect_to(trucks_path)
    end
  end
end
