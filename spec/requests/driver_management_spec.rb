require 'rails_helper'

RSpec.describe "/driver_managements", type: :request do
  let(:company) { create(:company) } # Create a company
  let(:admin) { create(:user, company: company, role: "admin") } # Admin user
  let(:driver) { create(:user, company: company, role: "driver") } # Driver user
  let(:other_company) { create(:company) } # Another company for isolation testing
  let(:other_driver) { create(:user, company: other_company, role: "driver") } # Driver from another company

  let(:valid_attributes) do
    {
      first_name: "John",
      last_name: "Doe",
      drivers_license: "ALFT2864",
      email: "john.doe@gmail.com",
      password: "password123",
      password_confirmation: "password123",
      company_id: company.id
    }
  end

  let(:invalid_attributes) do
    {
      first_name: nil,
      last_name: nil,
      email: nil,
      password: "password123",
      password_confirmation: "password123"
    }
  end

  describe "when the current_user is an admin" do
    before do
      sign_in admin, scope: :user
    end

    describe "GET /new" do
      it "renders a successful response for an admin user" do
        get new_driver_management_url
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new driver for the current company" do
          expect {
            post driver_managements_url, params: { user: valid_attributes }
          }.to change(User, :count).by(1)
          created_driver = User.last
          expect(created_driver.company).to eq(company)
          expect(created_driver.role).to eq("driver")
        end

        it "redirects to the admin index" do
          post driver_managements_url, params: { user: valid_attributes }
          expect(response).to redirect_to(admin_index_url)
        end
      end

      context "with invalid parameters" do
        it "does not create a new driver" do
          expect {
            post driver_managements_url, params: { user: invalid_attributes }
          }.to change(User, :count).by(0)
        end

        it "renders an unprocessable_entity response" do
          post driver_managements_url, params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /edit" do
      it "renders a successful response for a driver from the current company" do
        get edit_driver_management_url(driver)
        expect(response).to be_successful
      end
    end

    describe "PATCH /update" do
      let(:new_attributes) do
        {
          first_name: "Jane",
          last_name: "Doe",
          drivers_license: "D7654321"
        }
      end

      context "with valid parameters" do
        it "updates the requested driver" do
          patch driver_management_url(driver), params: { user: new_attributes }
          driver.reload
          expect(driver.first_name).to eq("Jane")
          expect(driver.last_name).to eq("Doe")
          expect(driver.drivers_license).to eq("D7654321")
        end

        it "redirects to the admin index" do
          patch driver_management_url(driver), params: { user: new_attributes }
          expect(response).to redirect_to(admin_index_url)
        end
      end

      context "with invalid parameters" do
        it "does not update the driver" do
          patch driver_management_url(driver), params: { user: invalid_attributes }
          driver.reload
          expect(driver.first_name).not_to eq(nil)
        end

        it "renders an unprocessable_entity response" do
          patch driver_management_url(driver), params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "when the current_user is a driver" do
    before do
      sign_in driver, scope: :user
    end

    describe "GET /new" do
      it "redirects non-admin users to the root path" do
        get new_driver_management_url
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "GET /edit" do
      it "redirects non-admin users to the root path" do
        get edit_driver_management_url(driver)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end
  end
end
