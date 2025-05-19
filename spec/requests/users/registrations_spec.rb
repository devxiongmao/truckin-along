require 'rails_helper'

RSpec.describe "Users::RegistrationsController", type: :request do
  let(:valid_attributes) {
    { email: "test@example.com", password: "password", password_confirmation: "password", first_name: "Frank", last_name: "Dillenger", drivers_license: "87654321" }
  }

  let(:invalid_attributes) {
    { email: "", password: "password", password_confirmation: "password" } # Invalid because email is blank
  }

  describe "GET /users/sign_up/customer" do
    it "renders a successful response" do
      get new_customer_registration_url
      expect(response).to be_successful
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post user_registration_path, params: { user: valid_attributes }
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.role).to eq("admin")
      end

      it "redirects to the dashboard path" do
        post user_registration_path, params: { user: valid_attributes }
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new user" do
        expect {
          post user_registration_path, params: { user: invalid_attributes }
        }.to change(User, :count).by(0)
      end

      it "renders a response with 422 status (to display the 'new' template)" do
        post user_registration_path, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
