require 'rails_helper'

RSpec.describe "/dashboard", type: :request do
  let(:customer) { create(:user, :customer) }
  let(:driver) { create(:user, :driver) }

  context "when a user is a customer" do
    before do
      sign_in customer, scope: :user
    end

    describe "GET /" do
      it "renders a successful response" do
        get dashboard_url
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get dashboard_url
        expect(response).to render_template(:index)
      end
    end
  end

  context "when a user is not a customer" do
    before do
      sign_in driver, scope: :user
    end

    describe "GET /" do
      it "renders a successful response" do
        get dashboard_url
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get dashboard_url
        expect(response).to render_template(:index)
      end
    end
  end

  describe "when a user is not signed in" do
    it "redicts to the sign in page" do
      get dashboard_url
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
