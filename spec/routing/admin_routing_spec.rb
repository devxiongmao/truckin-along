require "rails_helper"

RSpec.describe AdminController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin").to route_to("admin#index")
    end
  end
end
