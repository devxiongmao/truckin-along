require 'rails_helper'

RSpec.describe "/companies", type: :request do
  let(:valid_user) { create(:user) }
  let(:valid_attributes) {
    {
      name: "Test Company",
      address: "123 Test Street"
    }
  }

  let(:invalid_attributes) {
    {
      name: nil,       # Missing required field
      address: nil     # Missing required field
    }
  }

  before do
    sign_in valid_user, scope: :user
  end

  describe "GET /new" do
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

      it "redirects to the edit page for the company" do
        post companies_url, params: { company: valid_attributes }
        expect(response).to redirect_to(edit_company_url(Company.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Company" do
        expect {
          post companies_url, params: { company: invalid_attributes }
        }.to change(Company, :count).by(0)
      end

      it "renders a response with 422 status (i.e., to display the 'new' template)" do
        post companies_url, params: { company: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    let(:company) { create(:company) }

    before do
      valid_user.update!(company: company)
    end

    it "renders a successful response" do
      get edit_company_url(company)
      expect(response).to be_successful
    end

    it "redirects to the root path if the company is not found" do
      get edit_company_url(99999) # Non-existent ID
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Company not found.")
    end
  end

  describe "PATCH /update" do
    let(:company) { create(:company) }
    let(:new_attributes) {
      {
        name: "Updated Company",
        address: "456 Updated Street"
      }
    }

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
        expect(response).to redirect_to(edit_company_url(company))
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
    end
  end
end
