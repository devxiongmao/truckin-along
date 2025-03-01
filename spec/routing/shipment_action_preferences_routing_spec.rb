require "rails_helper"

RSpec.describe ShipmentActionPreferencesController, type: :routing do
  describe "routing" do
    it "routes to #edit" do
      expect(get: "/shipment_action_preferences/1/edit").to route_to("shipment_action_preferences#edit", id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/shipment_action_preferences/1").to route_to("shipment_action_preferences#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/shipment_action_preferences/1").to route_to("shipment_action_preferences#update", id: "1")
    end
  end
end
