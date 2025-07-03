require "rails_helper"

RSpec.describe OffersController, type: :routing do
  describe "routing" do
    it "routes to #index via GET" do
      expect(get: "/offers").to route_to("offers#index")
    end

    it "routes to #bulk_create via POST" do
      expect(post: "/offers/bulk_create").to route_to("offers#bulk_create")
    end

    it "routes to #accept via PATCH" do
      expect(patch: "/offers/1/accept").to route_to("offers#accept", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/offers/1/reject").to route_to("offers#reject", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/offers/1/withdraw").to route_to("offers#withdraw", id: "1")
    end
  end
end
