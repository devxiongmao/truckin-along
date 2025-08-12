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
      home_address: "1035 Sommerset Dr",
      email: "john.doe@gmail.com",
      password: "password123",
      password_confirmation: "password123"
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

  let(:new_attributes) do
    {
      first_name: "Jane",
      last_name: "Doe",
      drivers_license: "D7654321"
    }
  end

  describe "when the current_user is an admin" do
    before do
      sign_in admin, scope: :user
    end

    describe "GET /new" do
      it 'displays a new form' do
        get new_driver_management_url
        expect(response.body).to include("form")
      end

      it 'renders the new template' do
        get new_driver_management_url
        expect(response).to render_template(:new)
      end

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
          created_driver = User.last
          expect(created_driver.role).to eq("driver")
        end

        it 'assigns the current_users company to the driver' do
          post driver_managements_url, params: { user: valid_attributes }
          expect(User.last.company).to eq(company)
        end

        it "assigns a temporary password to the driver" do
          post driver_managements_url, params: { user: valid_attributes }
          created_driver = User.last
          expect(created_driver.encrypted_password).to be_present
        end

        it "sends a temporary password email" do
          expect {
            post driver_managements_url, params: { user: valid_attributes }
          }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it "redirects to the admin index" do
          post driver_managements_url, params: { user: valid_attributes }
          expect(response).to redirect_to(admin_index_url)
        end

        it 'has the appropriate flash message' do
          post driver_managements_url, params: { user: valid_attributes }
          expect(flash[:notice]).to eq("Driver account created successfully.")
        end
      end

      context "with invalid parameters" do
        it "does not create a new driver" do
          expect {
            post driver_managements_url, params: { user: invalid_attributes }
          }.to change(User, :count).by(0)
        end

        it "does not send an email when driver creation fails" do
          expect {
            post driver_managements_url, params: { user: invalid_attributes }
          }.not_to change { ActionMailer::Base.deliveries.count }
        end

        it "renders an unprocessable_content response" do
          post driver_managements_url, params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "re-renders the new template" do
          post driver_managements_url, params: { user: invalid_attributes }
          expect(response).to render_template(:new)
        end
      end
    end

    describe "GET /edit" do
      it "assigns the requested driver as @driver" do
        get edit_driver_management_url(driver)
        expect(response.body).to include(driver.first_name)
      end

      it "renders the edit template" do
        get edit_driver_management_url(driver)
        expect(response).to render_template(:edit)
      end

      it "renders a successful response" do
        get edit_driver_management_url(driver)
        expect(response).to be_successful
      end

      context "when the driver is from another company" do
        it 'redirects to the dashboard path' do
          get edit_driver_management_url(other_driver)
          expect(response).to redirect_to(dashboard_path)
        end

        it 'renders with an alert' do
          get edit_driver_management_url(other_driver)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end

    describe "PATCH /update" do
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

        it "renders an unprocessable_content response" do
          patch driver_management_url(driver), params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 're-renders the edit template' do
          patch driver_management_url(driver), params: { user: invalid_attributes }
          expect(response).to render_template(:edit)
        end
      end
    end

    describe "POST /reset_password" do
      context "with successful password reset" do
        it "updates the driver's password" do
          original_encrypted_password = driver.encrypted_password
          post reset_password_driver_management_url(driver)
          driver.reload
          expect(driver.encrypted_password).not_to eq(original_encrypted_password)
        end

        it "sends a reset password email" do
          expect {
            post reset_password_driver_management_url(driver)
          }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it "redirects to the admin index" do
          post reset_password_driver_management_url(driver)
          expect(response).to redirect_to(admin_index_url)
        end

        it "has the appropriate success flash message" do
          post reset_password_driver_management_url(driver)
          expect(flash[:notice]).to eq("Driver password was successfully reset.")
        end
      end

      context "when password reset fails" do
        before do
          allow_any_instance_of(User).to receive(:save).and_return(false)
        end

        it "does not send an email when password reset fails" do
          expect {
            post reset_password_driver_management_url(driver)
          }.not_to change { ActionMailer::Base.deliveries.count }
        end

        it "redirects to the admin index with error message" do
          post reset_password_driver_management_url(driver)
          expect(response).to redirect_to(admin_index_url)
          expect(flash[:alert]).to eq("Unable to reset password.")
        end
      end

      context "when the driver is from another company" do
        it 'redirects to the dashboard path' do
          post reset_password_driver_management_url(other_driver)
          expect(response).to redirect_to(dashboard_path)
        end

        it 'renders with an alert' do
          post reset_password_driver_management_url(other_driver)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end
  end

  describe "when the current_user is not an admin" do
    before do
      sign_in driver, scope: :user
    end

    describe "GET /new" do
      it "redirects non-admin users to the dashboard path" do
        get new_driver_management_url
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get new_driver_management_url
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe 'POST /create' do
      it "does not create the driver" do
        expect {
          post driver_managements_url, params: { user: valid_attributes }
        }.not_to change(User, :count)
      end

      it "redirects to the dashboard path" do
        post driver_managements_url, params: { user: valid_attributes }
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        post driver_managements_url, params: { user: valid_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET /edit" do
      it "redirects non-admin users to the dashboard path" do
        get edit_driver_management_url(driver)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get edit_driver_management_url(driver)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "PATCH /update" do
      it "does not update the driver" do
        patch driver_management_url(driver), params: { user: new_attributes }
        driver.reload
        expect(driver.first_name).not_to eq("Jane")
      end

      it "redirects to the dashboard path" do
        patch driver_management_url(driver), params: { user: new_attributes }
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        patch driver_management_url(driver), params: { user: new_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST /reset_password" do
      it "does not reset the driver's password" do
        original_encrypted_password = driver.encrypted_password
        post reset_password_driver_management_url(driver)
        driver.reload
        expect(driver.encrypted_password).to eq(original_encrypted_password)
      end

      it "does not send a reset password email" do
        expect {
          post reset_password_driver_management_url(driver)
        }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it "redirects to the dashboard path" do
        post reset_password_driver_management_url(driver)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        post reset_password_driver_management_url(driver)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
