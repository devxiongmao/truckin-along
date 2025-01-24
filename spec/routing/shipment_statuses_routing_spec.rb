require "rails_helper"

RSpec.describe ShipmentsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/shipment_statuses/new").to route_to("shipment_statuses#new")
    end

    it "routes to #edit" do
      expect(get: "/shipment_statuses/1/edit").to route_to("shipment_statuses#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/shipment_statuses").to route_to("shipment_statuses#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/shipment_statuses/1").to route_to("shipment_statuses#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/shipment_statuses/1").to route_to("shipment_statuses#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shipment_statuses/1").to route_to("shipment_statuses#destroy", id: "1")
    end
  end
end
