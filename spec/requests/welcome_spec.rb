require 'rails_helper'

RSpec.describe "/", type: :request do
  describe "GET /" do
    it "renders a successful response" do
      get root_url
      expect(response).to be_successful
    end
  end
end
