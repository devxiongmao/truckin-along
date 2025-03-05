require "rails_helper"

RSpec.describe DeliveriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/deliveries").to route_to("deliveries#index")
    end

    it "routes to #show" do
      expect(get: "/deliveries/1").to route_to("deliveries#show", id: "1")
    end

    it "routes to #load_truck" do
      expect(get: "/deliveries/load_truck").to route_to("deliveries#load_truck")
    end

    it "routes to #start" do
      expect(get: "/deliveries/start").to route_to("deliveries#start")
    end
  end
end
