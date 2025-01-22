require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:valid_user) { create(:user, role: "admin",) }
  let!(:company) { create(:company, name: "Test Company", address: "123 Test Street") }

  before do
    sign_in valid_user, scope: :user
  end

  describe 'GET #new' do
    it 'assigns a new company to @company and renders the new template' do
      get :new
      expect(assigns(:company)).to be_a_new(Company)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new company and assigns it to the current user' do
        expect {
          post :create, params: { company: { name: "New Company", address: "456 New Street" } }
        }.to change(Company, :count).by(1)

        expect(valid_user.reload.company).to eq(Company.last)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Company created successfully.")
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new company and re-renders the new template' do
        expect {
          post :create, params: { company: { name: "", address: "" } }
        }.not_to change(Company, :count)

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:alert]).to eq("Failed to create company.")
      end
    end
  end

  describe 'GET #edit' do
    before { valid_user.update!(company: company) }

    it 'assigns the requested company to @company and renders the edit template' do
      get :edit, params: { id: company.id }
      expect(assigns(:company)).to eq(company)
      expect(response).to render_template(:edit)
    end

    it 'redirects to the root path if the company is not found' do
      get :edit, params: { id: 99999 } # Non-existent ID
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Company not found.")
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) {
      { name: "Updated Company", address: "789 Updated Street" }
    }

    before { valid_user.update!(company: company) }

    context 'with valid attributes' do
      it 'updates the requested company and redirects to the edit page' do
        patch :update, params: { id: company.id, company: new_attributes }
        company.reload
        expect(company.name).to eq("Updated Company")
        expect(company.address).to eq("789 Updated Street")
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Company updated successfully.")
      end
    end

    context 'with invalid attributes' do
      it 'does not update the company and re-renders the edit template' do
        patch :update, params: { id: company.id, company: { name: "", address: "" } }
        company.reload
        expect(company.name).to eq("Test Company")
        expect(company.address).to eq("123 Test Street")
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq("Failed to update company.")
      end
    end
  end
end
