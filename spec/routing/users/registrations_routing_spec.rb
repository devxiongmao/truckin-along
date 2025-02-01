require "rails_helper"

RSpec.describe Users::RegistrationsController, type: :routing do
  describe "routing" do
    it "routes to #new (signup page)" do
      expect(get: "/users/sign_up").to route_to("users/registrations#new")
    end

    it "routes to #new (customer page)" do
      expect(get: "/users/sign_up/customer").to route_to("users/registrations#new_customer")
    end

    it "routes to #create (signup action)" do
      expect(post: "/users").to route_to("users/registrations#create")
    end

    it "routes to #cancel (cancel account)" do
      expect(get: "/users/cancel").to route_to("users/registrations#cancel")
    end

    it "routes to #edit (edit account settings)" do
      expect(get: "/users/edit").to route_to("users/registrations#edit")
    end

    it "routes to #update (update account settings) via PUT" do
      expect(put: "/users").to route_to("users/registrations#update")
    end

    it "routes to #update (update account settings) via PATCH" do
      expect(patch: "/users").to route_to("users/registrations#update")
    end

    it "routes to #destroy (delete account)" do
      expect(delete: "/users").to route_to("users/registrations#destroy")
    end
  end
end
