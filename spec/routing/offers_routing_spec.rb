require "rails_helper"

RSpec.describe OffersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/offers").to route_to("offers#index")
    end

    it "routes to #bulk_create" do
      expect(post: "/offers/bulk_create").to route_to("offers#bulk_create")
    end
  end
end
