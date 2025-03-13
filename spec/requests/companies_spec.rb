require 'rails_helper'

RSpec.describe "/companies", type: :request do
  let(:valid_user) { create(:user, role: "admin") }
  let(:non_admin_user) { create(:user) }

  let(:company) { create(:company) }

  let(:valid_attributes) {
    {
      name: "Test Company",
      address: "123 Test Street"
    }
  }

  let(:invalid_attributes) {
    {
      name: nil,
      address: nil
    }
  }

  let(:new_attributes) {
    {
      name: "Updated Company",
      address: "456 Updated Street"
    }
  }

  describe "when user is an admin" do
    before do
      sign_in valid_user, scope: :user
    end

    describe "GET /new" do
      it 'displays a new form' do
        get new_company_url
        expect(response.body).to include('form')
      end

      it 'renders the new template' do
        get new_company_url
        expect(response).to render_template(:new)
      end

      it "renders a successful response" do
        get new_company_url
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new Company" do
          expect {
            post companies_url, params: { company: valid_attributes }
          }.to change(Company, :count).by(1)
        end

        it "assigns the new company to the current user" do
          post companies_url, params: { company: valid_attributes }
          expect(valid_user.reload.company).to eq(Company.last)
        end

        it "redirects to the root page" do
          post companies_url, params: { company: valid_attributes }
          expect(response).to redirect_to(root_url)
        end

        it 'renders the correct flash response' do
          post companies_url, params: { company: valid_attributes }
          expect(flash[:notice]).to eq("Company created successfully.")
        end

        it 'creates the default shipment statuses' do
          expect {
            post companies_url, params: { company: valid_attributes }
          }.to change(ShipmentStatus, :count).by(3)
        end

        it 'creates the default shipment action preferences' do
          expect {
            post companies_url, params: { company: valid_attributes }
          }.to change(ShipmentActionPreference, :count).by(4)
        end
      end

      context "with invalid parameters" do
        it "does not create a new Company" do
          expect {
            post companies_url, params: { company: invalid_attributes }
          }.to change(Company, :count).by(0)
        end

        it 're-renders the new template' do
          post companies_url, params: { company: invalid_attributes }
          expect(response).to render_template(:new)
        end

        it "renders a response with 422 status" do
          post companies_url, params: { company: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the correct flash message' do
          post companies_url, params: { company: invalid_attributes }
          expect(flash[:alert]).to eq("Failed to create company.")
        end

        it 'does not create the default shipment statuses' do
          expect {
            post companies_url, params: { company: invalid_attributes }
          }.to change(ShipmentStatus, :count).by(0)
        end

        it 'does not create the default shipment action preferences' do
          expect {
            post companies_url, params: { company: invalid_attributes }
          }.to change(ShipmentActionPreference, :count).by(0)
        end
      end
    end

    describe "GET /edit" do
      before do
        valid_user.update!(company: company)
      end

      context "when the company is found" do
        it 'assigns the requested company to @company' do
          get edit_company_url(company)
          expect(response.body).to include(company.name)
        end

        it 'renders the edit template' do
          get edit_company_url(company)
          expect(response).to render_template(:edit)
        end

        it "renders a successful response" do
          get edit_company_url(company)
          expect(response).to be_successful
        end
      end

      context "when the company is not found" do
        it 'redirects to the root path' do
          get edit_company_url(99999)
          expect(response).to redirect_to(root_path)
        end

        it 'renders the correct flash alert' do
          get edit_company_url(99999)
          expect(flash[:alert]).to eq("Company not found.")
        end
      end
    end

    describe "PATCH /update" do
      before do
        valid_user.update!(company: company)
      end

      context "with valid parameters" do
        it "updates the requested company" do
          patch company_url(company), params: { company: new_attributes }
          company.reload
          expect(company.name).to eq("Updated Company")
          expect(company.address).to eq("456 Updated Street")
        end

        it "redirects to the edit page for the company" do
          patch company_url(company), params: { company: new_attributes }
          expect(response).to redirect_to(root_url)
        end
      end

      context "with invalid parameters" do
        it "does not update the company" do
          patch company_url(company), params: { company: invalid_attributes }
          company.reload
          expect(company.name).not_to be_nil
        end

        it "renders a response with 422 status (i.e., to display the 'edit' template)" do
          patch company_url(company), params: { company: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "re-renders the edit template)" do
          patch company_url(company), params: { company: invalid_attributes }
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "when user is not an admin" do
    before do
      sign_in non_admin_user, scope: :user
    end

    describe 'GET /new' do
      it 'redirects to the root path' do
        get new_company_url
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        get new_company_url
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    describe 'POST /create' do
      it "does not create a new Company" do
        expect {
          post companies_url, params: { company: valid_attributes }
        }.not_to change(Company, :count)
      end

      it 'redirects to the root path' do
        post companies_url, params: { company: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        post companies_url, params: { company: valid_attributes }
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    describe 'GET /edit' do
      before { non_admin_user.update!(company: company) }

      it 'redirects to the root path' do
        get edit_company_url(company)
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        get edit_company_url(company)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    describe 'PATCH /update' do
      let(:new_attributes) {
        { name: "Updated Company", address: "789 Updated Street" }
      }

      before { non_admin_user.update!(company: company) }

      it 'does not update the company' do
        patch company_url(company), params: { company: new_attributes }
        company.reload
        expect(company.name).not_to eq("Updated Company")
      end

      it 'redirects to the root path' do
        patch company_url(company), params: { company: new_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'renders with an error message' do
        patch company_url(company), params: { company: new_attributes }
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end
end
