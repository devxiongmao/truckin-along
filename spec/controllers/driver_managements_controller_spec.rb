require 'rails_helper'

RSpec.describe DriverManagementsController, type: :controller do
  let(:admin_user) { User.create!(email: "admin@example.com", password: "password", role: "admin") }
  let(:non_admin_user) { User.create!(email: "user@example.com", password: "password", role: "driver") }

  let!(:driver) { User.create!(first_name: "John", last_name: "Doe", drivers_license: "12345", email: "driver@example.com", password: "password", role: "driver") }

  before do
    sign_in admin_user
  end

  describe 'GET #index' do
    context 'as an admin' do
      it 'assigns all drivers to @drivers and renders the index template' do
        get :index
        expect(assigns(:drivers)).to eq([ driver ])
        expect(response).to render_template(:index)
      end
    end

    context 'as a non-admin' do
      it 'redirects to the root path with an alert' do
        sign_out admin_user
        sign_in non_admin_user

        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new driver to @driver and renders the new template' do
      get :new
      expect(assigns(:driver)).to be_a_new(User)
      expect(assigns(:driver).role).to eq("driver")
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new driver and redirects to the index page' do
        expect {
          post :create, params: {
            user: {
              first_name: "Jane",
              last_name: "Smith",
              drivers_license: "54321",
              email: "jane@example.com",
              password: "password",
              password_confirmation: "password"
            }
          }
        }.to change(User.drivers, :count).by(1)

        expect(response).to redirect_to(driver_managements_path)
        expect(flash[:notice]).to eq("Driver account created successfully.")
      end
    end
  end

  describe 'Authorization' do
    it 'redirects non-admin users attempting to access #new' do
      sign_out admin_user
      sign_in non_admin_user

      get :new
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Not authorized.")
    end

    it 'redirects non-admin users attempting to create a driver' do
      sign_out admin_user
      sign_in non_admin_user

      post :create, params: {
        user: {
          first_name: "Jane",
          last_name: "Smith",
          drivers_license: "54321",
          email: "jane@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Not authorized.")
    end
  end
end
