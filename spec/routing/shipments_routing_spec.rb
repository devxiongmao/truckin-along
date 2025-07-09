require "rails_helper"

RSpec.describe ShipmentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shipments").to route_to("shipments#index")
    end

    it "routes to #new" do
      expect(get: "/shipments/new").to route_to("shipments#new")
    end

    it "routes to #show" do
      expect(get: "/shipments/1").to route_to("shipments#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/shipments/1/edit").to route_to("shipments#edit", id: "1")
    end

    it "routes to #copy" do
      expect(get: "/shipments/1/copy").to route_to("shipments#copy", id: "1")
    end

    it "routes to #close" do
      expect(post: "/shipments/1/close").to route_to("shipments#close", id: "1")
    end

    it "routes to #create" do
      expect(post: "/shipments").to route_to("shipments#create")
    end

    it "routes to #assign_shipments_to_truck" do
      expect(post: "/shipments/assign_shipments_to_truck").to route_to("shipments#assign_shipments_to_truck")
    end

    it "routes to #initiate_delivery" do
      expect(post: "/shipments/initiate_delivery").to route_to("shipments#initiate_delivery")
    end

    it "routes to #update via PUT" do
      expect(put: "/shipments/1").to route_to("shipments#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/shipments/1").to route_to("shipments#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shipments/1").to route_to("shipments#destroy", id: "1")
    end
  end
end
