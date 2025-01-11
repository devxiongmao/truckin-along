require "rails_helper"

RSpec.describe DriverManagementsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/driver_managements").to route_to("driver_managements#index")
    end

    it "routes to #new" do
      expect(get: "/driver_managements/new").to route_to("driver_managements#new")
    end

    it "routes to #create" do
      expect(post: "/driver_managements").to route_to("driver_managements#create")
    end
  end
end
