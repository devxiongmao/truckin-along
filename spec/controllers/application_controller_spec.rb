require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    # Define a dummy controller to test ApplicationController behavior
    def index
      render plain: "Hello, world!"
    end
  end

  describe "before_action filters" do
    context "when the user is a customer" do
      before do
        allow(controller).to receive(:user_signed_in?).and_return(true)
        routes.draw { get "index" => "anonymous#index" }
      end

      it "does not redirect" do
        user = instance_double("User", customer?: true)
        allow(controller).to receive(:current_user).and_return(user)

        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context "when devise_controller?" do
      before do
        allow(controller).to receive(:devise_controller?).and_return(true)
        routes.draw { get "index" => "anonymous#index" }
      end

      it "configures permitted parameters" do
        expect(controller).to receive(:configure_permitted_parameters)
        get :index
      end
    end

    context "when not a devise_controller?" do
      before do
        allow(controller).to receive(:devise_controller?).and_return(false)
        allow(controller).to receive(:user_signed_in?).and_return(true)
        routes.draw { get "index" => "anonymous#index" }
      end

      it "redirects to new_company_path if user has no company" do
        user = instance_double("User", has_company?: false, customer?: false)
        allow(controller).to receive(:current_user).and_return(user)

        get :index
        expect(response).to redirect_to(new_company_path)
        expect(flash[:alert]).to eq("You must register a company before accessing the application.")
      end

      it "does not redirect if user has a company" do
        user = instance_double("User", has_company?: true, customer?: false)
        allow(controller).to receive(:current_user).and_return(user)

        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    it "skips redirection for companies or welcome controllers" do
      user = instance_double("User", customer?: false)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:controller_name).and_return("companies")
      allow(controller).to receive(:user_signed_in?).and_return(true)

      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#current_company" do
    it "returns the company associated with the current user" do
      company = instance_double("Company")
      user = instance_double("User", company: company)
      allow(controller).to receive(:current_user).and_return(user)

      expect(controller.current_company).to eq(company)
    end

    it "returns nil if there is no current user" do
      allow(controller).to receive(:current_user).and_return(nil)
      expect(controller.current_company).to be_nil
    end
  end

  describe "#configure_permitted_parameters" do
    let(:sanitizer) { instance_double("Devise::ParameterSanitizer") }

    before do
      allow(controller).to receive(:devise_parameter_sanitizer).and_return(sanitizer)
    end

    it "permits custom parameters for sign_up" do
      expect(sanitizer).to receive(:permit).with(:sign_up, keys: [ :first_name, :last_name, :drivers_license, :role ])
      allow(sanitizer).to receive(:permit) # To handle other calls without error

      controller.send(:configure_permitted_parameters)
    end

    it "permits custom parameters for account_update" do
      expect(sanitizer).to receive(:permit).with(:account_update, keys: [ :first_name, :last_name, :drivers_license, :role ])
      allow(sanitizer).to receive(:permit) # To handle other calls without error

      controller.send(:configure_permitted_parameters)
    end
  end
end
