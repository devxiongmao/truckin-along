require "rails_helper"

RSpec.describe DeliveriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/deliveries").to route_to("deliveries#index")
    end
  end
end
