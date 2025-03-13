require 'rails_helper'

RSpec.describe "/shipment_action_preferences", type: :request do
  let(:company) { create(:company) } # Create a company
  let(:user) { create(:user, :admin, company: company) } # Create a user tied to the company
  let(:non_admin_user) { create(:user, company: company) } # Create a user tied to the company

  let(:other_company) { create(:company) } # Another company for isolation testing

  let!(:shipment_status) { create(:shipment_status, company: company) } # A status belonging to the current company
  let!(:other_shipment_status) { create(:shipment_status, company: other_company) } # A status from another company

  let!(:company_preference) { create(:shipment_action_preference, company: company, shipment_status: shipment_status) } # A shipment action preference belonging to the current company
  let!(:other_company_preference) { create(:shipment_action_preference, company: other_company, shipment_status: other_shipment_status) } # A shipment action preference from another company

  let(:invalid_attributes) do
    {
      company_id: nil
    }
  end

  let(:new_attributes) do
    {
      shipment_status_id: nil
    }
  end

  describe "when the user is an admin" do
    before do
      sign_in user, scope: :user
    end

    describe "GET /edit" do
      it "assigns the requested shipment_action_preference as @preference" do
        get edit_shipment_action_preference_url(company_preference)
        expect(response.body).to include(shipment_status.name)
        expect(response.body).not_to include(other_shipment_status.name)
      end

      it "renders the edit template" do
        get edit_shipment_action_preference_url(company_preference)
        expect(response).to render_template(:edit)
      end

      it "renders a successful response" do
        get edit_shipment_action_preference_url(company_preference)
        expect(response).to be_successful
      end

      context "when the shipment action preference belongs to another company" do
        it 'redirects to the root path' do
          get edit_shipment_action_preference_url(other_company_preference)
          expect(response).to redirect_to(root_path)
        end

        it 'renders with an alert' do
          get edit_shipment_action_preference_url(other_company_preference)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        it "updates the requested shipment status" do
          patch shipment_action_preference_url(company_preference), params: { shipment_action_preference: new_attributes }
          company_preference.reload
          expect(company_preference.shipment_status_id).to be_nil
        end

        it "redirects to the admin index" do
          patch shipment_action_preference_url(company_preference), params: { shipment_action_preference: new_attributes }
          expect(response).to redirect_to(admin_index_url)
        end
      end

      context "with invalid parameters" do
        it "does not update the shipment status" do
          patch shipment_action_preference_url(company_preference), params: { shipment_action_preference: invalid_attributes }
          company_preference.reload
          expect(company_preference.company_id).not_to eq(nil)
        end

        it "renders an unprocessable_entity response" do
          patch shipment_action_preference_url(company_preference), params: { shipment_action_preference: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "re-renders the edit template" do
          patch shipment_action_preference_url(company_preference), params: { shipment_action_preference: invalid_attributes }
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "when the user is not an admin" do
    before do
      sign_in non_admin_user, scope: :user
    end

    describe "GET /edit" do
      it "redirects to the root path" do
        get edit_shipment_action_preference_url(company_preference)
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        get edit_shipment_action_preference_url(company_preference)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "PATCH /update" do
      it "does not update the shipment status" do
        patch shipment_action_preference_url(company_preference), params: { shipment_action_preference: new_attributes }
        company_preference.reload
        expect(company_preference.shipment_status_id).not_to be_nil
      end

      it "redirects to the root path" do
        patch shipment_action_preference_url(company_preference), params: { shipment_action_preference: new_attributes }
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        patch shipment_action_preference_url(company_preference), params: { shipment_action_preference: new_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
