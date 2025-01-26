require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:valid_user) { create(:user, :admin) }
  let(:non_admin_user) { create(:user) }

  let!(:company) { create(:company) }

  describe "when user is an admin" do
    before do
      sign_in valid_user, scope: :user
    end

    describe 'GET #new' do
      it 'assigns a new company to @company ' do
        get :new
        expect(assigns(:company)).to be_a_new(Company)
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
        it 'creates a new company' do
          expect {
            post :create, params: { company: { name: "New Company", address: "456 New Street" } }
          }.to change(Company, :count).by(1)
        end

        it 'assigns the new company to the current user' do
          post :create, params: { company: { name: "New Company", address: "456 New Street" } }
          expect(valid_user.reload.company).to eq(Company.last)
        end

        it 'redirects to the root path' do
          post :create, params: { company: { name: "New Company", address: "456 New Street" } }
          expect(response).to redirect_to(root_path)
        end

        it 'renders the correct flash response' do
          post :create, params: { company: { name: "New Company", address: "456 New Street" } }
          expect(flash[:notice]).to eq("Company created successfully.")
        end
      end

      context 'with invalid attributes' do
        it 'does not create a new company' do
          expect {
            post :create, params: { company: { name: "", address: "" } }
          }.not_to change(Company, :count)
        end

        it 're-renders the new template' do
          post :create, params: { company: { name: "", address: "" } }
          expect(response).to render_template(:new)
        end

        it 'responds with unprocessable_entity' do
          post :create, params: { company: { name: "", address: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the correct flash message' do
          post :create, params: { company: { name: "", address: "" } }
          expect(flash.now[:alert]).to eq("Failed to create company.")
        end
      end
    end

    describe 'GET #edit' do
      before { valid_user.update!(company: company) }

      context "when the company is found" do
        it 'assigns the requested company to @company' do
          get :edit, params: { id: company.id }
          expect(assigns(:company)).to eq(company)
        end

        it 'renders the edit template' do
          get :edit, params: { id: company.id }
          expect(response).to render_template(:edit)
        end

        it "responds successfully" do
          get :edit, params: { id: company.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the company is not found" do
        it 'redirects to the root path' do
          get :edit, params: { id: 99999 } # Non-existent ID
          expect(response).to redirect_to(root_path)
        end

        it 'renders the correct flash alert' do
          get :edit, params: { id: 99999 } # Non-existent ID
          expect(flash[:alert]).to eq("Company not found.")
        end
      end
    end

    describe 'PATCH #update' do
      let(:new_attributes) {
        { name: "Updated Company", address: "789 Updated Street" }
      }

      before { valid_user.update!(company: company) }

      context 'with valid attributes' do
        it 'updates the requested company' do
          patch :update, params: { id: company.id, company: new_attributes }
          company.reload
          expect(company.name).to eq("Updated Company")
          expect(company.address).to eq("789 Updated Street")
        end

        it 'redirects to the root path' do
          patch :update, params: { id: company.id, company: new_attributes }
          expect(response).to redirect_to(root_path)
        end

        it 'responds with found' do
          patch :update, params: { id: company.id, company: new_attributes }
          expect(response).to have_http_status(:found)
        end

        it 'renders the correct flash alert' do
          patch :update, params: { id: company.id, company: new_attributes }
          expect(flash[:notice]).to eq("Company updated successfully.")
        end
      end

      context 'with invalid attributes' do
        it 'does not update the company' do
          company_name = company.name
          company_address = company.address
          patch :update, params: { id: company.id, company: { name: "", address: "" } }
          company.reload
          expect(company.name).to eq(company_name)
          expect(company.address).to eq(company_address)
        end

        it 're-renders the edit template' do
          patch :update, params: { id: company.id, company: { name: "", address: "" } }
          expect(response).to render_template(:edit)
        end

        it 'responds with unprocessable_entity' do
          patch :update, params: { id: company.id, company: { name: "", address: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the correct flash alert' do
          patch :update, params: { id: company.id, company: { name: "", address: "" } }
          expect(flash[:alert]).to eq("Failed to update company.")
        end
      end
    end
  end

  describe "when user is not an admin" do
    before do
      sign_in non_admin_user, scope: :user
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

    describe 'POST #create' do
      it 'redirects to the root path' do
        post :create, params: { company: { name: "New Company", address: "456 New Street" } }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        post :create, params: { company: { name: "New Company", address: "456 New Street" } }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe 'GET #edit' do
      before { non_admin_user.update!(company: company) }

      it 'redirects to the root path' do
        get :edit, params: { id: company.id }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        get :edit, params: { id: company.id }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end

    describe 'PATCH #update' do
      let(:new_attributes) {
        { name: "Updated Company", address: "789 Updated Street" }
      }

      before { non_admin_user.update!(company: company) }

      it 'redirects to the root path' do
        patch :update, params: { id: company.id, company: new_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        patch :update, params: { id: company.id, company: new_attributes }
        expect(flash[:alert]).to eq('Not authorized.')
      end
    end
  end
end
