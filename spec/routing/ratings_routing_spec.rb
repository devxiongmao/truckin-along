require "rails_helper"

RSpec.describe RatingsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/ratings").to route_to("ratings#create")
    end
  end
end
