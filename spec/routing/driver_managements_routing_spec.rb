require "rails_helper"

RSpec.describe DriverManagementsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/driver_managements/new").to route_to("driver_managements#new")
    end

    it "routes to #create" do
      expect(post: "/driver_managements").to route_to("driver_managements#create")
    end

    it "routes to #edit" do
      expect(get: "/driver_managements/1/edit").to route_to("driver_managements#edit", id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/driver_managements/1").to route_to("driver_managements#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/driver_managements/1").to route_to("driver_managements#update", id: "1")
    end

    it "routes to #reset_password" do
      expect(post: "/driver_managements/1/reset_password").to route_to("driver_managements#reset_password", id: "1")
    end
  end
end
