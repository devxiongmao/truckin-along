require 'rails_helper'

RSpec.describe "/shipment_statuses", type: :request do
  let(:company) { create(:company) } # Create a company
  let(:user) { create(:user, :admin, company: company) } # Create a user tied to the company
  let(:non_admin_user) { create(:user, company: company) } # Create a user tied to the company

  let(:other_company) { create(:company) } # Another company for isolation testing

  let!(:shipment_status) { create(:shipment_status, company: company) } # A status belonging to the current company
  let!(:other_shipment_status) { create(:shipment_status, company: other_company) } # A status from another company

  let(:valid_attributes) do
    {
      name: "In Transit",
      company_id: company.id
    }
  end

  let(:invalid_attributes) do
    {
      name: nil
    }
  end

  let(:new_attributes) do
    {
      name: "Delivered"
    }
  end

  describe "when the user is an admin" do
    before do
      sign_in user, scope: :user
    end

    describe "GET /new" do
      it "renders a new form" do
        get new_shipment_status_url
        expect(response.body).to include("form")
      end

      it "renders the new template" do
        get new_shipment_status_url
        expect(response).to render_template(:new)
      end

      it "renders a successful response" do
        get new_shipment_status_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "assigns the requested shipment_status as @shipment_status" do
        get edit_shipment_status_url(shipment_status)
        expect(response.body).to include(shipment_status.name)
      end

      it "renders the edit template" do
        get edit_shipment_status_url(shipment_status)
        expect(response).to render_template(:edit)
      end

      it "renders a successful response" do
        get edit_shipment_status_url(shipment_status)
        expect(response).to be_successful
      end

      context "when the shipment status belongs to another company" do
        it 'redirects to the root path' do
          get edit_shipment_status_url(other_shipment_status)
          expect(response).to redirect_to(root_path)
        end

        it 'renders with an alert' do
          get edit_shipment_status_url(other_shipment_status)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new ShipmentStatus" do
          expect {
            post shipment_statuses_url, params: { shipment_status: valid_attributes }
          }.to change(ShipmentStatus, :count).by(1)
        end

        it "assigns the new status to the current company" do
          post shipment_statuses_url, params: { shipment_status: valid_attributes }
          created_status = ShipmentStatus.last
          expect(created_status.company).to eq(company)
        end

        it "redirects to the admin index" do
          post shipment_statuses_url, params: { shipment_status: valid_attributes }
          expect(response).to redirect_to(admin_index_url)
        end
      end

      context "with invalid parameters" do
        it "does not create a new ShipmentStatus" do
          expect {
            post shipment_statuses_url, params: { shipment_status: invalid_attributes }
          }.to change(ShipmentStatus, :count).by(0)
        end

        it "renders an unprocessable_entity response" do
          post shipment_statuses_url, params: { shipment_status: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "re-renders the new template" do
          post shipment_statuses_url, params: { shipment_status: invalid_attributes }
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        it "updates the requested shipment status" do
          patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
          shipment_status.reload
          expect(shipment_status.name).to eq("Delivered")
        end

        it "redirects to the admin index" do
          patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
          expect(response).to redirect_to(admin_index_url)
        end
      end

      context "with invalid parameters" do
        it "does not update the shipment status" do
          patch shipment_status_url(shipment_status), params: { shipment_status: invalid_attributes }
          shipment_status.reload
          expect(shipment_status.name).not_to eq(nil)
        end

        it "renders an unprocessable_entity response" do
          patch shipment_status_url(shipment_status), params: { shipment_status: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "re-renders the edit template" do
          patch shipment_status_url(shipment_status), params: { shipment_status: invalid_attributes }
          expect(response).to render_template(:edit)
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested shipment status" do
        expect {
          delete shipment_status_url(shipment_status)
        }.to change(ShipmentStatus, :count).by(-1)
      end

      it "redirects to the admin index" do
        delete shipment_status_url(shipment_status)
        expect(response).to redirect_to(admin_index_url)
      end
    end
  end

  describe "when the user is not an admin" do
    before do
      sign_in non_admin_user, scope: :user
    end

    describe "GET /new" do
      it "redirects to the root path" do
        get new_shipment_status_url
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        get new_shipment_status_url
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "GET /edit" do
      it "redirects to the root path" do
        get edit_shipment_status_url(shipment_status)
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        get edit_shipment_status_url(shipment_status)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "POST /create" do
      it "does not create the shipment status" do
        expect {
          post shipment_statuses_url, params: { shipment_status: valid_attributes }
        }.not_to change(ShipmentStatus, :count)
      end

      it "redirects to the root path" do
        post shipment_statuses_url, params: { shipment_status: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        post shipment_statuses_url, params: { shipment_status: valid_attributes }
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "PATCH /update" do
      it "does not update the shipment status" do
        patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
        shipment_status.reload
        expect(shipment_status.name).not_to eq("Delivered")
      end

      it "redirects to the root path" do
        patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        patch shipment_status_url(shipment_status), params: { shipment_status: new_attributes }
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    describe "DELETE /destroy" do
      it "does not destroy the shipmen statust" do
        expect {
          delete shipment_status_url(shipment_status)
        }.not_to change(ShipmentStatus, :count)
      end

      it "redirects to the root path" do
        delete shipment_status_url(shipment_status)
        expect(response).to redirect_to(root_path)
      end

      it "renders the correct flash alert" do
        delete shipment_status_url(shipment_status)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end
  end
end
