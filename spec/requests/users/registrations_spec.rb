require 'rails_helper'

RSpec.describe "Users::RegistrationsController", type: :request do
  let(:valid_attributes) {
    {
      email: "test@example.com",
      password: "password",
      password_confirmation: "password",
      first_name: "Frank",
      last_name: "Dillenger",
      drivers_license: "87654321"
    }
  }

  let(:invalid_attributes) {
    { email: "", password: "password", password_confirmation: "password" }
  }

  describe "GET /users/sign_up/customer" do
    it "renders a successful response" do
      get new_customer_registration_url
      expect(response).to be_successful
    end

    it "assigns a new user with role 'customer'" do
      get new_customer_registration_url
      expect(assigns(:user)).to be_a_new(User)
      expect(assigns(:user).role).to eq("customer")
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user with default role 'admin'" do
        expect {
          post user_registration_path, params: { user: valid_attributes }
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.role).to eq("admin")
      end

      it "creates a new user with overridden role 'customer'" do
        expect {
          post user_registration_path, params: { user: valid_attributes.merge(role: "customer") }
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.role).to eq("customer")
      end

      it "redirects to the dashboard path after sign up" do
        post user_registration_path, params: { user: valid_attributes }
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new user" do
        expect {
          post user_registration_path, params: { user: invalid_attributes }
        }.not_to change(User, :count)
      end

      it "renders a response with 422 status" do
        post user_registration_path, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PUT /users" do
    let(:user) { create(:user, password: "password") }

    before do
      sign_in user
    end

    it "updates the user password" do
      put user_registration_path, params: {
        user: {
          current_password: "password",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }

      user.reload
      expect(user.valid_password?("newpassword123")).to be true
    end

    it "redirects to dashboard" do
      put user_registration_path, params: {
        user: {
          current_password: "password",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }

      expect(response).to redirect_to(dashboard_path)
    end
  end
end
