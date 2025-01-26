require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'responds with a successful status' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
