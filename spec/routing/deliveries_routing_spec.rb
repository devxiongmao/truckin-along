require "rails_helper"

RSpec.describe DeliveriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/deliveries").to route_to("deliveries#index")
    end

    it "routes to #truck_loading" do
      expect(get: "/deliveries/truck_loading").to route_to("deliveries#truck_loading")
    end

    it "routes to #start_delivery" do
      expect(get: "/deliveries/start_delivery").to route_to("deliveries#start_delivery")
    end
  end
end
