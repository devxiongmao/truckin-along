require 'rails_helper'

RSpec.describe DriverManagementsController, type: :request do
  let(:admin_user) { create(:user, role: "admin") }
  let(:driver_user) { create(:user, email: "walle@rocket.com", role: "driver") }

  let(:valid_attributes) {
    { first_name: "John", last_name: "Doe", drivers_license: "A123456", email: "newdriver@example.com", password: "password", password_confirmation: "password" }
  }

  before do
    sign_in admin_user
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_driver_management_url
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new driver" do
        expect {
          post driver_managements_url, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it "redirects to the driver managements index page with a success notice" do
        post driver_managements_url, params: { user: valid_attributes }
        expect(response).to redirect_to(driver_managements_url)
        expect(flash[:notice]).to eq("Driver account created successfully.")
      end
    end
  end

  describe "GET /index" do
    it "renders a successful response" do
      get driver_managements_url
      expect(response).to be_successful
    end
  end

  describe "Unauthorized Access" do
    context "when the user is not an admin" do
      before do
        sign_in driver_user
      end

      it "redirects to the root path with an alert" do
        get driver_managements_url
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end
  end
end
