require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  let(:valid_user) { create(:user, :customer) }
  let(:other_user) { create(:user, :customer) }

  let(:company) { create(:company) }

  let(:admin_user) { create(:user, :admin, company: company) }
  let(:shipment_status) { create(:shipment_status) }

  let!(:shipment) { create(:shipment, user: valid_user) }
  let!(:other_shipment) { create(:shipment, user: other_user) }

  let(:valid_attributes) do
    {
      name: "New Shipment",
      shipment_status_id: shipment_status.id,
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
      shipment_status_id: nil,
      sender_name: nil,
      sender_address: nil,
      receiver_name: nil,
      receiver_address: nil,
      weight: nil,
      boxes: nil
    }
  end

  context "when user is a customer" do
    before do
      sign_in valid_user, scope: :user
    end

    describe 'GET #index' do
      it "assigns @shipments to shipments that belong to the current user" do
        get :index
        expect(assigns(:shipments)).to include(shipment)
        expect(assigns(:shipments)).not_to include(other_shipment)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "responds successfully" do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET #show' do
      context "when the shipment belongs to the user" do
        it 'assigns the requested shipment to @shipment' do
          get :show, params: { id: shipment.id }
          expect(assigns(:shipment)).to eq(shipment)
        end

        it "renders the show template" do
          get :show, params: { id: shipment.id }
          expect(response).to render_template(:show)
        end

        it "responds successfully" do
          get :show, params: { id: shipment.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the shipment does not belong to the user" do
        it "redirects to the shipments index" do
          get :show, params: { id: other_shipment.id }
          expect(response).to redirect_to(shipments_path)
        end

        it "shows an alert saying not authorized" do
          get :show, params: { id: other_shipment.id }
          expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
        end
      end
    end

    describe "GET #new" do
      it "assigns a new shipment as @shipment" do
        get :new
        expect(assigns(:shipment)).to be_a_new(Shipment)
      end

      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end

      it "responds successfully" do
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET #edit" do
      context "when the shipment belongs to the user" do
        it "assigns the requested shipment as @shipment" do
          get :edit, params: { id: shipment.id }
          expect(assigns(:shipment)).to eq(shipment)
        end

        it "renders the edit template" do
          get :edit, params: { id: shipment.id }
          expect(response).to render_template(:edit)
        end

        it "responds successfully" do
          get :edit, params: { id: shipment.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the shipment does not belong to the user" do
        it "redirects to the shipments index" do
          get :edit, params: { id: other_shipment.id }
          expect(response).to redirect_to(shipments_path)
        end

        it "shows an alert saying not authorized" do
          get :edit, params: { id: other_shipment.id }
          expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
        end
      end
    end

    describe "POST #create" do
      context "with valid parameters" do
        it 'creates a new shipment' do
          expect {
            post :create, params: { shipment: valid_attributes }
          }.to change(Shipment, :count).by(1)
        end

        it 'creates a new shipment and redirects to the show page' do
          post :create, params: { shipment: valid_attributes }
          expect(response).to redirect_to(shipment_path(assigns(:shipment)))
        end
      end

      context "with invalid parameters" do
        it "does not create a new shipment" do
          expect {
            post :create, params: { shipment: invalid_attributes }
          }.to change(Shipment, :count).by(0)
        end

        it "renders the new template with unprocessable_entity status" do
          post :create, params: { shipment: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH #update" do
      let(:new_attributes) do
        {
          name: "Toys"
        }
      end

      context "when the shipment belongs to the user" do
        context "with valid parameters" do
          it "updates the requested shipment" do
            patch :update, params: { id: shipment.id, shipment: new_attributes }
            shipment.reload
            expect(shipment.name).to eq("Toys")
          end

          it "redirects to the shipments show path" do
            patch :update, params: { id: shipment.id, shipment: new_attributes }
            expect(response).to redirect_to(shipment_path(shipment))
          end

          it "shows a notice saying the shipment was updated" do
            patch :update, params: { id: shipment.id, shipment: new_attributes }
            expect(flash[:notice]).to eq("Shipment was successfully updated.")
          end
        end

        context "with invalid parameters" do
          it "does not update the shipment" do
            patch :update, params: { id: shipment.id, shipment: invalid_attributes }
            shipment.reload
            expect(shipment.name).not_to eq(nil)
          end

          it "responds with unprocessable_entity status" do
            patch :update, params: { id: shipment.id, shipment: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 're-renders the edit template' do
            patch :update, params: { id: shipment.id, shipment: { name: '' } }
            expect(response).to render_template(:edit)
          end
        end
      end

      context "when the shipment does not belong to the user" do
        it "redirects to the shipments index" do
          patch :update, params: { id: other_shipment.id, shipment: new_attributes }
          expect(response).to redirect_to(shipments_path)
        end

        it "shows an alert saying not authorized" do
          patch :update, params: { id: other_shipment.id, shipment: new_attributes }
          expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
        end
      end
    end

    describe "DELETE #destroy" do
      context "when the shipment belongs to the user" do
        it "destroys the requested shipment" do
          shipment
          expect {
            delete :destroy, params: { id: shipment.id }
          }.to change(Shipment, :count).by(-1)
        end

        it "redirects to the shipments list" do
          delete :destroy, params: { id: shipment.id }
          expect(response).to redirect_to(shipments_path)
        end
      end

      context "when the shipment does not belong to the user" do
        it "redirects to the shipments index" do
          delete :destroy, params: { id: other_shipment.id }
          expect(response).to redirect_to(shipments_path)
        end

        it "shows an alert saying not authorized" do
          delete :destroy, params: { id: other_shipment.id }
          expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
        end
      end
    end

    describe "POST #assign" do
      it 'redirects to the root page' do
        post :assign, params: { shipment_ids: [] }
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        post :assign, params: { shipment_ids: [] }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST #assign_shipments_to_truck" do
      it 'redirects to the root' do
        post :assign, params: { shipment_ids: [] }
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        post :assign, params: { shipment_ids: [] }
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
        get :index
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        get :index
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe 'GET #show' do
      context "when the shipment is unclaimed" do
        let!(:shipment) { create(:shipment, user: valid_user, company: nil) }

        it 'assigns the requested shipment to @shipment' do
          get :show, params: { id: shipment.id }
          expect(assigns(:shipment)).to eq(shipment)
        end

        it "renders the show template" do
          get :show, params: { id: shipment.id }
          expect(response).to render_template(:show)
        end

        it "responds successfully" do
          get :show, params: { id: shipment.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the shipment is claimed" do
        context "by the users company" do
          let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company) }

          it 'assigns the requested shipment to @shipment' do
            get :show, params: { id: claimed_shipment.id }
            expect(assigns(:shipment)).to eq(claimed_shipment)
          end

          it "renders the show template" do
            get :show, params: { id: claimed_shipment.id }
            expect(response).to render_template(:show)
          end

          it "responds successfully" do
            get :show, params: { id: claimed_shipment.id }
            expect(response).to have_http_status(:ok)
          end
        end

        context "by a different company" do
          let(:company2) { create(:company) }
          let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company2) }

          it 'redirects to the deliveries page' do
            get :show, params: { id: claimed_shipment.id }
            expect(response).to redirect_to(deliveries_path)
          end

          it "shows an alert saying not authorized" do
            get :show, params: { id: claimed_shipment.id }
            expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
          end
        end
      end
    end

    describe "GET #new" do
      it 'redirects to the root page' do
        get :new
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        get :new
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET #edit" do
      context "when the shipment is unclaimed" do
        let!(:shipment) { create(:shipment, user: valid_user, company: nil) }

        it 'redirects to the deliveries page' do
          get :edit, params: { id: shipment.id }
          expect(response).to redirect_to(deliveries_path)
        end

        it "shows an alert saying not authorized" do
          get :edit, params: { id: shipment.id }
          expect(flash[:alert]).to eq("You are not authorized to modify this shipment.")
        end
      end

      context "when the shipment is claimed" do
        context "by the users company" do
          let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company) }

          it 'assigns the requested shipment to @shipment' do
            get :edit, params: { id: claimed_shipment.id }
            expect(assigns(:shipment)).to eq(claimed_shipment)
          end

          it "renders the show template" do
            get :edit, params: { id: claimed_shipment.id }
            expect(response).to render_template(:edit)
          end

          it "responds successfully" do
            get :edit, params: { id: claimed_shipment.id }
            expect(response).to have_http_status(:ok)
          end
        end

        context "by a different company" do
          let(:company2) { create(:company) }
          let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company2) }


          it 'redirects to the deliveries page' do
            get :edit, params: { id: claimed_shipment.id }
            expect(response).to redirect_to(deliveries_path)
          end

          it "shows an alert saying not authorized" do
            get :edit, params: { id: claimed_shipment.id }
            expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
          end
        end
      end
    end

    describe "POST #create" do
      it 'redirects to the root page' do
        post :create, params: { shipment: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it "shows an alert saying not authorized" do
        post :create, params: { shipment: valid_attributes }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "PATCH #update" do
      let(:new_attributes) do
        {
          name: "Toys"
        }
      end

      context "with valid parameters" do
        context "when the shipment is unclaimed" do
          let!(:shipment) { create(:shipment, user: valid_user, company: nil) }

          it "shows an alert saying not authorized" do
            patch :update, params: { id: shipment.id, shipment: new_attributes }
            expect(flash[:alert]).to eq("You are not authorized to modify this shipment.")
          end

          it "redirects to the deliveries path" do
            patch :update, params: { id: shipment.id, shipment: new_attributes }
            expect(response).to redirect_to(deliveries_path)
          end
        end

        context "when the shipment is claimed" do
          context "by the users company" do
            let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company) }

            it 'updates the shipment' do
              patch :update, params: { id: claimed_shipment.id, shipment: new_attributes }
              claimed_shipment.reload
              expect(claimed_shipment.name).to eq("Toys")
            end

            it "redirects to the shipments show path" do
              patch :update, params: { id: claimed_shipment.id, shipment: new_attributes }
              expect(response).to redirect_to(shipment_path(claimed_shipment))
            end
          end

          context "by a different company" do
            let(:company2) { create(:company) }
            let!(:claimed_shipment) { create(:shipment, user: valid_user, company: company2) }

            it "shows an alert saying not authorized" do
              patch :update, params: { id: claimed_shipment.id, shipment: new_attributes }
              expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
            end

            it "redirects to the deliveries path" do
              patch :update, params: { id: claimed_shipment.id, shipment: new_attributes }
              expect(response).to redirect_to(deliveries_path)
            end
          end
        end
      end

      context "with invalid parameters" do
        context "when the shipment is unclaimed" do
          let!(:shipment) { create(:shipment, user: valid_user, company: nil) }

          it "does not update the shipment" do
            patch :update, params: { id: shipment.id, shipment: invalid_attributes }
            shipment.reload
            expect(shipment.name).not_to eq(nil)
          end

          it 'redirects to the deliveries page' do
            patch :update, params: { id: shipment.id, shipment: invalid_attributes }
            expect(response).to redirect_to(deliveries_path)
          end

          it "shows an alert saying not authorized" do
            patch :update, params: { id: shipment.id, shipment: invalid_attributes }
            expect(flash[:alert]).to eq("You are not authorized to modify this shipment.")
          end
        end

        context "when the shipment is claimed" do
          context "by the current users company" do
            let!(:shipment) { create(:shipment, user: valid_user, company: company) }

            it "does not update the shipment" do
              patch :update, params: { id: shipment.id, shipment: invalid_attributes }
              shipment.reload
              expect(shipment.name).not_to eq(nil)
            end

            it "responds with unprocessable_entity status" do
              patch :update, params: { id: shipment.id, shipment: invalid_attributes }
              expect(response).to have_http_status(:unprocessable_entity)
            end

            it 're-renders the edit template' do
              patch :update, params: { id: shipment.id, shipment: invalid_attributes }
              expect(response).to render_template(:edit)
            end
          end

          context "by a different company" do
            let(:company2) { create(:company) }

            let!(:shipment) { create(:shipment, user: valid_user, company: company2) }

            it "does not update the shipment" do
              patch :update, params: { id: shipment.id, shipment: invalid_attributes }
              shipment.reload
              expect(shipment.name).not_to eq(nil)
            end

            it 'redirects to the deliveries page' do
              patch :update, params: { id: shipment.id, shipment: invalid_attributes }
              expect(response).to redirect_to(deliveries_path)
            end

            it "shows an alert saying not authorized" do
              patch :update, params: { id: shipment.id, shipment: invalid_attributes }
              expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
            end
          end
        end
      end
    end

    describe "DELETE #destroy" do
      it 'redirects to the root page' do
        delete :destroy, params: { id: shipment.id }
        expect(response).to redirect_to(deliveries_path)
      end

      it "shows an alert saying not authorized" do
        delete :destroy, params: { id: shipment.id }
        expect(flash[:alert]).to eq("You are not authorized to access this shipment.")
      end
    end

    describe "POST #assign" do
      let!(:unassigned_shipment) { create(:shipment, user: valid_user, company: nil) }
      let!(:unassigned_shipment2) { create(:shipment, user: other_user, company: nil) }

      let!(:unassigned_shipments) { [ unassigned_shipment, unassigned_shipment2 ] }

      it "assigns selected shipments to the current company" do
        shipment_ids = unassigned_shipments.map(&:id)
        post :assign, params: { shipment_ids: shipment_ids }

        unassigned_shipments.each do |shipment|
          shipment.reload
          expect(shipment.company.id).to eq(admin_user.company.id)
        end
      end

      it "redirects to the deliveries path" do
        post :assign, params: { shipment_ids: [] }
        expect(response).to redirect_to(deliveries_path)
      end

      it "shows an alert saying shipments have been assigned" do
        shipment_ids = unassigned_shipments.map(&:id)
        post :assign, params: { shipment_ids: shipment_ids }
        expect(flash[:notice]).to eq("Selected shipments have been assigned to your company.")
      end

      it "shows an alert if no shipments are selected" do
        post :assign, params: { shipment_ids: [] }
        expect(flash[:alert]).to eq("No shipments were selected.")
      end
    end

    describe "POST #assign_shipments_to_truck" do
      context "with invalid params" do
        it 'redirects to the truck_loading_path' do
          post :assign_shipments_to_truck, params: { shipment_ids: [], truck_id: nil }
          expect(response).to redirect_to(truck_loading_deliveries_path)
        end

        it "shows an alert saying not authorized" do
          post :assign_shipments_to_truck, params: { shipment_ids: [], truck_id: nil }
          expect(flash[:alert]).to eq("Please select a truck and at least one shipment.")
        end
      end


      context "with valid params" do
        let(:truck) { create(:truck, company: company) }
        let(:claimed_shipment) { create(:shipment, company: company, truck: nil) }

        it "updates the shipments" do
          post :assign_shipments_to_truck, params: { shipment_ids: [ claimed_shipment.id ], truck_id: truck.id }
          claimed_shipment.reload
          expect(claimed_shipment.truck_id).to eq(truck.id)
        end

        it "redirects to the truck_loading path" do
          post :assign_shipments_to_truck, params: { shipment_ids: [ claimed_shipment.id ], truck_id: truck.id }
          expect(response).to redirect_to(truck_loading_deliveries_path)
        end

        it "shows the appropriate alert" do
          post :assign_shipments_to_truck, params: { shipment_ids: [ claimed_shipment.id ], truck_id: truck.id }
          expect(flash[:notice]).to eq("Shipments successfully assigned to truck #{truck.display_name}.")
        end
      end
    end
  end
end
