require 'rails_helper'

RSpec.describe DriverManagementsController, type: :controller do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }


  let(:admin_user) { create(:user, :admin, company: company) }
  let(:non_admin_user) { create(:user, company: company) }
  let(:other_non_admin_user) { create(:user, company: other_company) }

  let(:valid_attributes) do
    {
      first_name: "Jane",
      last_name: "Smith",
      drivers_license: "87654321",
      email: "jane@example.com",
      password: "password",
      password_confirmation: "password",
      company_id: company.id
    }
  end

  let(:invalid_attributes) do
    {
      first_name: nil
    }
  end

  describe "as an admin user" do
    before do
      sign_in admin_user, scope: :user
    end

    describe 'GET #new' do
      it 'assigns a new driver to @driver' do
        get :new
        expect(assigns(:driver)).to be_a_new(User)
        expect(assigns(:driver).role).to eq("driver")
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end

      it "responds successfully" do
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'creates a new driver' do
          expect {
            post :create, params: {
              user: valid_attributes
            }
          }.to change(User.drivers, :count).by(1)
        end

        it 'redirects to the admin page' do
          post :create, params: { user: valid_attributes }
          expect(response).to redirect_to(admin_index_path)
        end

        it 'has the appropriate flash message' do
          post :create, params: { user: valid_attributes }
          expect(flash[:notice]).to eq("Driver account created successfully.")
        end
      end
    end

    describe "GET #edit" do
      it "assigns the requested driver as @driver" do
        get :edit, params: { id: non_admin_user.id }
        expect(assigns(:driver)).to eq(non_admin_user)
      end

      it "renders the edit template" do
        get :edit, params: { id: non_admin_user.id }
        expect(response).to render_template(:edit)
      end

      it "raises ActiveRecord::RecordNotFound for a driver from another company" do
        expect {
          get :edit, params: { id: other_non_admin_user.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "responds successfully" do
        get :edit, params: { id: non_admin_user.id }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PATCH #update" do
      let(:new_attributes) do
        {
          first_name: "Tim"
        }
      end

      context "with valid parameters" do
        it "updates the requested driver" do
          patch :update, params: { id: non_admin_user.id, user: new_attributes }
          non_admin_user.reload
          expect(non_admin_user.first_name).to eq("Tim")
        end

        it "redirects to the admin_index_path" do
          patch :update, params: { id: non_admin_user.id, user: new_attributes }
          expect(response).to redirect_to(admin_index_path)
        end
      end

      context "with invalid parameters" do
        it "does not update the driver" do
          patch :update, params: { id: non_admin_user.id, user: invalid_attributes }
          non_admin_user.reload
          expect(non_admin_user.first_name).not_to eq(nil)
        end

        it "renders the edit template with unprocessable_entity status" do
          patch :update, params: { id: non_admin_user.id, user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
        end

        it 're-renders the edit template' do
          patch :update, params: { id: non_admin_user.id, user: invalid_attributes }
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "as a non-admin user" do
    before do
      sign_in non_admin_user, scope: :user
    end

    describe 'GET #new' do
      it 'redirects to the root path' do
        get :new
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an alert' do
        get :new
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe 'POST #create' do
      it 'redirects to the root path' do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        post :create, params: { user: valid_attributes }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe 'GET #edit' do
      it 'redirects to the root path' do
        get :edit, params: { id: non_admin_user.id }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        get :edit, params: { id: non_admin_user.id }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe 'PATCH #update' do
      it 'redirects to the root path' do
        patch :update, params: { id: non_admin_user.id, user: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        patch :update, params: { id: non_admin_user.id, user: valid_attributes }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end
  end
end
