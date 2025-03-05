require 'rails_helper'

RSpec.describe "/shipments", type: :request do
  let!(:valid_user) { create(:user, :customer) }
  let!(:other_user) { create(:user, :customer) }

  let!(:company) { create(:company) }

  let(:admin_user) { create(:user, :admin, company: company) }

  let!(:shipment) { create(:shipment, user: valid_user) }
  let!(:other_shipment) { create(:shipment, user: other_user) }

  let(:valid_attributes) do
    {
      name: "New Shipment",
      sender_name: "Sender",
      sender_address: "123 Street",
      receiver_name: "Receiver",
      receiver_address: "456 Avenue",
      weight: 50.0,
      length: 50.0,
      width: 20.0,
      height: 22.5,
      boxes: 5
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      sender_name: nil,
      sender_address: nil,
      receiver_name: nil,
      receiver_address: nil,
      weight: nil,
      boxes: nil
    }
  end

  let(:new_attributes) do
    {
      name: "Toys"
    }
  end

  context "when user is a customer" do
    before do
      sign_in valid_user, scope: :user
    end

    describe 'GET #index' do
      it "assigns @shipments to shipments that belong to the current user" do
        get shipments_url
        expect(response.body).to include(shipment.name)
        expect(response.body).not_to include(other_shipment.name)
      end

      it "renders the index template" do
        get shipments_url
        expect(response).to render_template(:index)
      end

      it "responds successfully" do
        get shipments_url
        expect(response).to be_successful
      end
    end

    describe 'GET #show' do
      context "when the shipment belongs to the user" do
        it 'assigns the requested shipment to @shipment' do
          get shipment_url(shipment)
          expect(response.body).to include(shipment.name)
        end

        it "renders the show template" do
          get shipment_url(shipment)
          expect(response).to render_template(:show)
        end

        it "responds successfully" do
          get shipment_url(shipment)
          expect(response).to be_successful
        end
      end

      context "when the shipment does not belong to the user" do
        it "redirects to the shipments index" do
          get shipment_url(other_shipment)
          expect(response).to redirect_to(shipments_path)
        end

        it "shows an alert saying not authorized" do
          get shipment_url(other_shipment)
          expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
        end
      end
    end

    describe "GET #new" do
      it "renders a new form" do
        get new_shipment_url
        expect(response.body).to include('form')
      end

      it "renders the new template" do
        get new_shipment_url
        expect(response).to render_template(:new)
      end

      it "responds successfully" do
        get new_shipment_url
        expect(response).to be_successful
      end
    end

    describe "GET #edit" do
      context "when the shipment belongs to the user" do
        it "assigns the requested shipment as @shipment" do
          get edit_shipment_url(shipment)
          expect(response.body).to include(shipment.name)
        end

        it "renders the edit template" do
          get edit_shipment_url(shipment)
          expect(response).to render_template(:edit)
        end

        it "responds successfully" do
          get edit_shipment_url(shipment)
          expect(response).to be_successful
        end
      end

      context "when the shipment does not belong to the user" do
        it "redirects to the shipments index" do
          get edit_shipment_url(other_shipment)
          expect(response).to redirect_to(shipments_path)
        end

        it "shows an alert saying not authorized" do
          get edit_shipment_url(other_shipment)
          expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
        end
      end
    end

    describe "POST #create" do
      context "with valid parameters" do
        it 'creates a new shipment' do
          expect {
            post shipments_url, params: { shipment: valid_attributes }
          }.to change(Shipment, :count).by(1)
        end

        it 'creates a new shipment and redirects to the show page' do
          post shipments_url, params: { shipment: valid_attributes }
          expect(response).to redirect_to(shipment_path(Shipment.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new shipment" do
          expect {
            post shipments_url, params: { shipment: invalid_attributes }
          }.to change(Shipment, :count).by(0)
        end

        it "responds with unprocessable_entity status" do
          post shipments_url, params: { shipment: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders the new template" do
          post shipments_url, params: { shipment: invalid_attributes }
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH #update" do
      context "when the shipment belongs to the user" do
        context "with valid parameters" do
          it "updates the requested shipment" do
            patch shipment_url(shipment), params: { shipment: new_attributes }
            shipment.reload
            expect(shipment.name).to eq("Toys")
          end

          it "redirects to the shipments show path" do
            patch shipment_url(shipment), params: { shipment: new_attributes }
            expect(response).to redirect_to(shipment_path(shipment))
          end

          it "shows a notice saying the shipment was updated" do
            patch shipment_url(shipment), params: { shipment: new_attributes }
            expect(flash[:notice]).to eq("Shipment was successfully updated.")
          end
        end

        context "with invalid parameters" do
          it "does not update the shipment" do
            patch shipment_url(shipment), params: { shipment: invalid_attributes }
            shipment.reload
            expect(shipment.name).not_to eq(nil)
          end

          it "responds with unprocessable_entity status" do
            patch shipment_url(shipment), params: { shipment: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 're-renders the edit template' do
            patch shipment_url(shipment), params: { shipment: invalid_attributes }
            expect(response).to render_template(:edit)
          end
        end
      end

      context "when the shipment does not belong to the user" do
        it "redirects to the shipments index" do
          patch shipment_url(other_shipment), params: { shipment: new_attributes }
          expect(response).to redirect_to(shipments_path)
        end

        it "shows an alert saying not authorized" do
          patch shipment_url(other_shipment), params: { shipment: new_attributes }
          expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
        end
      end
    end

    describe "DELETE #destroy" do
      context "when the shipment belongs to the user" do
        it "destroys the requested shipment" do
          shipment
          expect {
            delete shipment_url(shipment)
          }.to change(Shipment, :count).by(-1)
        end

        it "redirects to the shipments list" do
          delete shipment_url(shipment)
          expect(response).to redirect_to(shipments_path)
        end
      end

      context "when the shipment does not belong to the user" do
        it "redirects to the shipments index" do
          delete shipment_url(other_shipment)
          expect(response).to redirect_to(shipments_path)
        end

        it "shows an alert saying not authorized" do
          delete shipment_url(other_shipment)
          expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
        end
      end
    end

    describe "POST #assign" do
      it 'redirects to the root page' do
        post assign_shipments_url, params: { shipment_ids: [] }
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        post assign_shipments_url, params: { shipment_ids: [] }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST #assign_shipments_to_truck" do
      it 'redirects to the root' do
        post assign_shipments_to_truck_shipments_url, params: { shipment_ids: [], truck_id: nil }
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        post assign_shipments_to_truck_shipments_url, params: { shipment_ids: [], truck_id: nil }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST #initiate_delivery" do
      it 'redirects to the root' do
        post initiate_delivery_shipments_url, params: { truck_id: 1 }
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        post initiate_delivery_shipments_url, params: { truck_id: 1 }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  context "when user is not a customer" do
    before do
      sign_in admin_user, scope: :user
    end

    describe 'GET #index' do
      it 'redirects to the root page' do
        get shipments_url
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        get shipments_url
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe 'GET #show' do
      context "when the shipment is unclaimed" do
        let!(:shipment) { create(:shipment, user: valid_user, company: nil) }

        it 'assigns the requested shipment to @shipment' do
          get shipment_url(shipment)
          expect(response.body).to include(shipment.name)
        end

        it "renders the show template" do
          get shipment_url(shipment)
          expect(response).to render_template(:show)
        end

        it "responds successfully" do
          get shipment_url(shipment)
          expect(response).to be_successful
        end
      end

      context "when the shipment is claimed" do
        context "by the users company" do
          let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company) }

          it 'assigns the requested shipment to @shipment' do
            get shipment_url(claimed_shipment)
            expect(assigns(:shipment)).to eq(claimed_shipment)
          end

          it "renders the show template" do
            get shipment_url(claimed_shipment)
            expect(response).to render_template(:show)
          end

          it "responds successfully" do
            get shipment_url(claimed_shipment)
            expect(response).to be_successful
          end
        end

        context "by a different company" do
          let(:company2) { create(:company) }
          let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company2) }

          it 'redirects to the deliveries page' do
            get shipment_url(claimed_shipment)
            expect(response).to redirect_to(deliveries_path)
          end

          it "shows an alert saying not authorized" do
            get shipment_url(claimed_shipment)
            expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
          end
        end
      end
    end

    describe "GET #new" do
      it 'redirects to the root page' do
        get new_shipment_url
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        get new_shipment_url
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET #edit" do
      context "when the shipment is unclaimed" do
        let!(:shipment) { create(:shipment, user: valid_user, company: nil) }

        it 'redirects to the deliveries page' do
          get edit_shipment_url(shipment)
          expect(response).to redirect_to(deliveries_path)
        end

        it "shows an alert saying not authorized" do
          get edit_shipment_url(shipment)
          expect(flash[:alert]).to eq("You are not authorized to modify this shipment.")
        end
      end

      context "when the shipment is claimed" do
        context "by the users company" do
          let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company) }

          it 'assigns the requested shipment to @shipment' do
            get edit_shipment_url(claimed_shipment)
            expect(response.body).to include(claimed_shipment.name)
          end

          it "renders the show template" do
            get edit_shipment_url(claimed_shipment)
            expect(response).to render_template(:edit)
          end

          it "responds successfully" do
            get edit_shipment_url(claimed_shipment)
            expect(response).to be_successful
          end
        end

        context "by a different company" do
          let(:company2) { create(:company) }
          let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company2) }

          it 'redirects to the deliveries page' do
            get edit_shipment_url(claimed_shipment)
            expect(response).to redirect_to(deliveries_path)
          end

          it "shows an alert saying not authorized" do
            get edit_shipment_url(claimed_shipment)
            expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
          end
        end
      end
    end

    describe "POST #create" do
      it 'does not create a shipment' do
        expect {
          post shipments_url, params: { shipment: valid_attributes }
      }.not_to change(Shipment, :count)
      end

      it 'redirects to the root page' do
        post shipments_url, params: { shipment: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        post shipments_url, params: { shipment: valid_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "PATCH #update" do
      context "with valid parameters" do
        context "when the shipment is unclaimed" do
          let!(:shipment) { create(:shipment, user: valid_user, company: nil) }

          it "shows an alert saying not authorized" do
            patch shipment_url(shipment), params: { shipment: new_attributes }
            expect(flash[:alert]).to eq("You are not authorized to modify this shipment.")
          end

          it "redirects to the deliveries path" do
            patch shipment_url(shipment), params: { shipment: new_attributes }
            expect(response).to redirect_to(deliveries_path)
          end
        end

        context "when the shipment is claimed" do
          context "by the users company" do
            let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company) }

            it 'updates the shipment' do
              patch shipment_url(claimed_shipment), params: { shipment: new_attributes }
              claimed_shipment.reload
              expect(claimed_shipment.name).to eq("Toys")
            end

            it "redirects to the shipments show path" do
              patch shipment_url(claimed_shipment), params: { shipment: new_attributes }
              expect(response).to redirect_to(shipment_path(claimed_shipment))
            end
          end

          context "by a different company" do
            let(:company2) { create(:company) }
            let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company2) }

            it "shows an alert saying not authorized" do
              patch shipment_url(claimed_shipment), params: { shipment: new_attributes }
              expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
            end

            it "redirects to the deliveries path" do
              patch shipment_url(claimed_shipment), params: { shipment: new_attributes }
              expect(response).to redirect_to(deliveries_path)
            end
          end
        end
      end

      context "with invalid parameters" do
        context "when the shipment is unclaimed" do
          let!(:shipment) { create(:shipment, user: valid_user, company: nil) }

          it "does not update the shipment" do
            patch shipment_url(shipment), params: { shipment: invalid_attributes }
            shipment.reload
            expect(shipment.name).not_to eq(nil)
          end

          it 'redirects to the deliveries page' do
            patch shipment_url(shipment), params: { shipment: invalid_attributes }
            expect(response).to redirect_to(deliveries_path)
          end

          it "shows an alert saying not authorized" do
            patch shipment_url(shipment), params: { shipment: invalid_attributes }
            expect(flash[:alert]).to eq("You are not authorized to modify this shipment.")
          end
        end

        context "when the shipment is claimed" do
          context "by the current users company" do
            let!(:shipment) { create(:shipment, user: valid_user, company: company) }

            it "does not update the shipment" do
              patch shipment_url(shipment), params: { shipment: invalid_attributes }
              shipment.reload
              expect(shipment.name).not_to eq(nil)
            end

            it "responds with unprocessable_entity status" do
              patch shipment_url(shipment), params: { shipment: invalid_attributes }
              expect(response).to have_http_status(:unprocessable_entity)
            end

            it 're-renders the edit template' do
              patch shipment_url(shipment), params: { shipment: invalid_attributes }
              expect(response).to render_template(:edit)
            end
          end

          context "by a different company" do
            let(:company2) { create(:company) }

            let!(:shipment) { create(:shipment, user: valid_user, company: company2) }

            it "does not update the shipment" do
              patch shipment_url(shipment), params: { shipment: invalid_attributes }
              shipment.reload
              expect(shipment.name).not_to eq(nil)
            end

            it 'redirects to the deliveries page' do
              patch shipment_url(shipment), params: { shipment: invalid_attributes }
              expect(response).to redirect_to(deliveries_path)
            end

            it "shows an alert saying not authorized" do
              patch shipment_url(shipment), params: { shipment: invalid_attributes }
              expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
            end
          end
        end
      end
    end

    describe "DELETE #destroy" do
      it 'redirects to the root page' do
        delete shipment_url(shipment)
        expect(response).to redirect_to(deliveries_path)
      end

      it "shows an alert saying not authorized" do
        delete shipment_url(shipment)
        expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
      end
    end

    describe "POST #assign" do
      let!(:unassigned_shipment) { create(:shipment, user: valid_user, company: nil) }
      let!(:unassigned_shipment2) { create(:shipment, user: other_user, company: nil) }

      let!(:unassigned_shipments) { [ unassigned_shipment, unassigned_shipment2 ] }

      it "assigns selected shipments to the current company" do
        shipment_ids = unassigned_shipments.map(&:id)
        post assign_shipments_url, params: { shipment_ids: shipment_ids }

        unassigned_shipments.each do |shipment|
          shipment.reload
          expect(shipment.company.id).to eq(admin_user.company.id)
        end
      end

      it "redirects to the deliveries path" do
        post assign_shipments_url, params: { shipment_ids: [] }
        expect(response).to redirect_to(deliveries_path)
      end

      it "shows an alert saying shipments have been assigned" do
        shipment_ids = unassigned_shipments.map(&:id)
        post assign_shipments_url, params: { shipment_ids: shipment_ids }
        expect(flash[:notice]).to eq("Selected shipments have been assigned to your company.")
      end

      it "shows an alert if no shipments are selected" do
        post assign_shipments_url, params: { shipment_ids: nil }
        expect(flash[:alert]).to eq("No shipments were selected.")
      end

      describe "when a shipment action preference exists" do
        let(:shipment_status) { create(:shipment_status, company: company) }
        let!(:company_preference) { create(:shipment_action_preference, action: "claimed_by_company", company: company, shipment_status: shipment_status) }

        it "updates the shipments to have that status" do
          shipment_ids = unassigned_shipments.map(&:id)
          post assign_shipments_url, params: { shipment_ids: shipment_ids }
          shipment = Shipment.find(shipment_ids.last)
          expect(shipment.shipment_status_id).to eq(shipment_status.id)
        end
      end
    end

    describe "POST #assign_shipments_to_truck" do
      context "with invalid params" do
        it 'redirects to the load_truck_path' do
          post assign_shipments_to_truck_shipments_url, params: { shipment_ids: [], truck_id: nil }
          expect(response).to redirect_to(load_truck_deliveries_path)
        end

        it "shows an alert saying not authorized" do
          post assign_shipments_to_truck_shipments_url, params: { shipment_ids: [], truck_id: nil }
          expect(flash[:alert]).to eq("Please select a truck and at least one shipment.")
        end
      end


      context "with valid params" do
        let(:truck) { create(:truck, company: company) }
        let(:claimed_shipment) { create(:shipment, company: company, truck: nil) }

        it "updates the shipments" do
          post assign_shipments_to_truck_shipments_url, params: { shipment_ids: [ claimed_shipment.id ], truck_id: truck.id }
          claimed_shipment.reload
          expect(claimed_shipment.truck_id).to eq(truck.id)
        end

        it "redirects to the load_truck path" do
          post assign_shipments_to_truck_shipments_url, params: { shipment_ids: [ claimed_shipment.id ], truck_id: truck.id }
          expect(response).to redirect_to(load_truck_deliveries_path)
        end

        it "shows the appropriate alert" do
          post assign_shipments_to_truck_shipments_url, params: { shipment_ids: [ claimed_shipment.id ], truck_id: truck.id }
          expect(flash[:notice]).to eq("Shipments successfully assigned to truck #{truck.display_name}.")
        end

        describe "when a shipment action preference exists" do
          let(:shipment_status) { create(:shipment_status, company: company) }
          let!(:company_preference) { create(:shipment_action_preference, action: "loaded_onto_truck", company: company, shipment_status: shipment_status) }

          it "updates the shipments to have that status" do
            post assign_shipments_to_truck_shipments_url, params: { shipment_ids: [ claimed_shipment.id ], truck_id: truck.id }
            claimed_shipment.reload
            expect(claimed_shipment.shipment_status_id).to eq(shipment_status.id)
          end
        end
      end
    end

    describe "POST #initiate_delivery" do
      context "with invalid params" do
        it 'redirects to the load_truck_path' do
          post initiate_delivery_shipments_url, params: { truck_id: nil }
          expect(response).to redirect_to(start_deliveries_path)
        end

        it "shows an alert saying not authorized" do
          post initiate_delivery_shipments_url, params: { truck_id: nil }
          expect(flash[:alert]).to eq([ "Failed to create delivery: Validation failed: Truck must exist" ])
        end
      end


      context "with valid params" do
        let(:truck) { create(:truck, company: company) }
        let!(:sample_shipment) { create(:shipment, company: company, truck: truck) }

        before do
          allow(InitiateDelivery).to receive(:new).and_call_original
        end

        it "calls the InitiateDelivery service" do
          post initiate_delivery_shipments_url, params: { truck_id: truck.id }
          expect(InitiateDelivery).to have_received(:new).with(instance_of(ActionController::Parameters), admin_user, company)
        end

        it "redirects to the created delivery with a success notice" do
          post initiate_delivery_shipments_url, params: { truck_id: truck.id }

          delivery = Delivery.last
          expect(response).to redirect_to(delivery)
          expect(flash[:notice]).to eq("Delivery was successfully created with #{delivery.shipments.count} shipments.")
        end
      end
    end
  end
end
