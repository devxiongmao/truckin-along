require 'rails_helper'

RSpec.describe DriverManagementsController, type: :controller do
  let(:company) { create(:company) }

  let(:admin_user) { create(:user, role: "admin", company: company) }
  let(:non_admin_user) { create(:user, email: "test_driver@gmail.com", role: "driver", company: company) }

  let!(:driver) { create(:user, email: "test_driver2@gmail.com", role: "driver", company: company) }

  describe "as an admin user" do
    before do
      sign_in admin_user, scope: :user
    end

    describe 'GET #index' do
      context 'as an admin' do
        it 'assigns all drivers to @drivers and renders the index template' do
          get :index
          expect(response).to render_template(:index)
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
                drivers_license: "87654321",
                email: "jane@example.com",
                password: "password",
                password_confirmation: "password",
                company_id: company.id
              }
            }
          }.to change(User.drivers, :count).by(1)

          expect(response).to redirect_to(driver_managements_path)
          expect(flash[:notice]).to eq("Driver account created successfully.")
        end
      end
    end
  end

  describe "as a non-admin user" do
    before do
      sign_in non_admin_user, scope: :user
    end

    describe 'GET #index' do
      it 'redirects to the root path with an alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe 'GET #new' do
      it 'redirects to the root path with an alert' do
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe 'Authorization' do
      it 'redirects non-admin users attempting to create a driver' do
        post :create, params: {
          user: {
            first_name: "Jane",
            last_name: "Smith",
            drivers_license: "87654321",
            email: "jane@example.com",
            password: "password",
            password_confirmation: "password",
            company_id: company.id
          }
        }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end
  end
end
