require "rails_helper"

RSpec.describe FormsController, type: :routing do
  describe "routing" do
    it "routes to #create_form" do
      expect(get: "/forms/1/show_modal").to route_to("forms#show_modal", id: "1")
    end
  end
end
