require 'rails_helper'

RSpec.describe "/deliveries", type: :request do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }

  let(:valid_user) { create(:user, company: company) }
  let(:other_user) { create(:user, company: other_company) }

  let(:non_org_user) { create(:user, :customer, company: company) }

  let!(:unassigned_shipment) { create(:shipment, company: nil) }
  let!(:assigned_shipment) { create(:shipment, company: company, truck: nil) }

  let!(:truck) { create(:truck, company: company) }
  let!(:inactive_truck) { create(:truck, company: company, active: false) }

  let!(:other_truck) { create(:truck, company: other_company) }

  let!(:delivery) { create(:delivery, user: valid_user, truck: truck, status: :scheduled) }
  let!(:form) { create(:form, :pre_delivery, formable: delivery) }
  let!(:other_delivery) { create(:delivery, user: other_user, truck: other_truck) }

  describe "when user is not a customer" do
    before do
      sign_in valid_user, scope: :user
    end

    describe "GET /index" do
      it "renders a successful response" do
        get deliveries_url
        expect(response).to be_successful
      end

      it "renders the correct template" do
        get deliveries_url
        expect(response).to render_template(:index)
      end

      context 'when no shipments exist' do
        before do
          Shipment.destroy_all
        end

        it "shows the correct data for my shipments" do
          get deliveries_url
          expect(response.body).to include("You have no shipments assigned to you.")
        end

        it "shows the correct data for unassigned shipments" do
          get deliveries_url
          expect(response.body).to include("No unassigned shipments available.")
        end

        it "renders the correct template" do
          get deliveries_url
          expect(response).to render_template(:index)
        end

        it 'responds successfully' do
          get deliveries_url
          expect(response).to be_successful
        end
      end
    end

    describe 'GET /show' do
      context "when the delivery belongs to the user" do
        it "renders the show template" do
          get delivery_url(delivery)
          expect(response).to render_template(:show)
        end

        it "responds successfully" do
          get delivery_url(delivery)
          expect(response).to be_successful
        end
      end

      context "when the delivery does not belong to the users company" do
        it "redirects to the dashboard" do
          get delivery_url(other_delivery)
          expect(response).to redirect_to(dashboard_path)
        end

        it "shows an alert saying not authorized" do
          get delivery_url(other_delivery)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end
      end
    end

    describe 'POST /close' do
      let(:valid_odometer_reading) { delivery.truck.mileage + 100 }
      let(:invalid_odometer_reading) { delivery.truck.mileage - 100 }

      context "when the delivery belongs to the user" do
        context "when all shipments are closed and odometer reading is valid" do
          let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery, delivered_date: Time.now) }
          let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery, delivered_date: Time.now) }

          it "redirects to the delivery start page" do
            post close_delivery_url(delivery), params: { odometer_reading: valid_odometer_reading }
            expect(response).to redirect_to(start_deliveries_url)
          end

          it "shows a notice saying delivery is closed" do
            post close_delivery_url(delivery), params: { odometer_reading: valid_odometer_reading }
            expect(flash[:notice]).to eq("Delivery complete!")
          end

          it "updates the delivery status to completed" do
            post close_delivery_url(delivery), params: { odometer_reading: valid_odometer_reading }
            expect(delivery.reload.status).to eq("completed")
          end

          it "updates the truck mileage" do
            expect {
              post close_delivery_url(delivery), params: { odometer_reading: valid_odometer_reading }
            }.to change { delivery.truck.reload.mileage }.to(valid_odometer_reading)
          end
        end

        context "when not all shipments are closed" do
          let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery) }
          let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery) }

          it "redirects to the delivery show page" do
            post close_delivery_url(delivery), params: { odometer_reading: valid_odometer_reading }
            expect(response).to redirect_to(delivery_url(delivery))
          end

          it "shows an alert saying shipments are still open" do
            post close_delivery_url(delivery), params: { odometer_reading: valid_odometer_reading }
            expect(flash[:alert]).to eq("Delivery still has open shipments. It cannot be closed at this time.")
          end

          it "does not close the delivery" do
            post close_delivery_url(delivery), params: { odometer_reading: valid_odometer_reading }
            expect(delivery.reload.status).not_to eq("completed")
          end

          it "does not update the truck mileage" do
            expect {
              post close_delivery_url(delivery), params: { odometer_reading: valid_odometer_reading }
            }.not_to change { delivery.truck.reload.mileage }
          end
        end

        context "when odometer reading is invalid" do
          let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery, delivered_date: Time.now) }
          let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery, delivered_date: Time.now) }

          it "redirects to the delivery show page" do
            post close_delivery_url(delivery), params: { odometer_reading: invalid_odometer_reading }
            expect(response).to redirect_to(delivery_url(delivery))
          end

          it "shows an alert saying odometer reading is incorrect" do
            post close_delivery_url(delivery), params: { odometer_reading: invalid_odometer_reading }
            expect(flash[:alert]).to eq("Odometer reading must be higher than previous value. Please revise.")
          end

          it "does not close the delivery" do
            post close_delivery_url(delivery), params: { odometer_reading: invalid_odometer_reading }
            expect(delivery.reload.status).not_to eq("completed")
          end

          it "does not update the truck mileage" do
            expect {
              post close_delivery_url(delivery), params: { odometer_reading: invalid_odometer_reading }
            }.not_to change { delivery.truck.reload.mileage }
          end
        end

        context "when odometer reading is missing" do
          let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery, delivered_date: Time.now) }
          let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery, delivered_date: Time.now) }

          it "redirects to the delivery show page" do
            post close_delivery_url(delivery)
            expect(response).to redirect_to(delivery_url(delivery))
          end

          it "shows an alert saying odometer reading is incorrect" do
            post close_delivery_url(delivery)
            expect(flash[:alert]).to eq("Odometer reading must be higher than previous value. Please revise.")
          end

          it "does not close the delivery" do
            post close_delivery_url(delivery)
            expect(delivery.reload.status).not_to eq("completed")
          end
        end
      end

      context "when the delivery does not belong to the users company" do
        it "redirects to the dashboard" do
          post close_delivery_url(other_delivery), params: { odometer_reading: valid_odometer_reading }
          expect(response).to redirect_to(dashboard_path)
        end

        it "shows an alert saying not authorized" do
          post close_delivery_url(other_delivery), params: { odometer_reading: valid_odometer_reading }
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end

        it "does not close the delivery" do
          post close_delivery_url(other_delivery), params: { odometer_reading: valid_odometer_reading }
          expect(other_delivery.reload.status).not_to eq("completed")
        end
      end
    end

    describe "GET /load_truck" do
      it "renders a successful response" do
        get load_truck_deliveries_url
        expect(response).to be_successful
      end

      it "assigns current companies shipments that don't have a truck to @unassigned_shipments" do
        get load_truck_deliveries_url
        expect(response.body).to include(assigned_shipment.name)
        expect(response.body).not_to include(unassigned_shipment.name)
      end

      it "assigns current companies trucks to @trucks" do
        get load_truck_deliveries_url
        expect(response.body).to include(truck.make)
        expect(response.body).not_to include(other_truck.make)
      end

      it "renders the correct template" do
        get load_truck_deliveries_url
        expect(response).to render_template(:load_truck)
      end

      it "renders only available trucks" do
        allow_any_instance_of(DeliveriesController).to receive(:load_truck).and_call_original

        get load_truck_deliveries_url

        expect(controller.instance_variable_get(:@trucks)).to contain_exactly(truck)
      end

      context 'when no shipments exist' do
        before do
          Shipment.destroy_all
        end

        it "shows the correct data for shipments" do
          get load_truck_deliveries_url
          expect(response.body).to include("No unassigned shipments available.")
        end

        it "renders the correct template" do
          get load_truck_deliveries_url
          expect(response).to render_template(:load_truck)
        end

        it 'responds successfully' do
          get load_truck_deliveries_url
          expect(response).to be_successful
        end
      end
    end

    describe "GET /start" do
      it "renders a successful response" do
        get start_deliveries_url
        expect(response).to be_successful
      end

      it "assigns current companies trucks to @trucks" do
        get start_deliveries_url
        expect(response.body).to include(truck.make)
        expect(response.body).not_to include(other_truck.make)
      end

      it "renders the correct template" do
        get start_deliveries_url
        expect(response).to render_template(:start)
      end

      context 'when no trucks exist' do
        before do
          Truck.destroy_all
        end

        it "shows the correct data for trucks" do
          get start_deliveries_url
          expect(response.body).to include("You don't have any trucks.")
        end

        it "renders the correct template" do
          get start_deliveries_url
          expect(response).to render_template(:start)
        end

        it 'responds successfully' do
          get start_deliveries_url
          expect(response).to be_successful
        end
      end
    end
  end

  describe "when the user is a customer" do
    before do
      sign_in non_org_user, scope: :user
    end

    describe "GET /index" do
      it "redirects to the dashboard path" do
        get deliveries_url
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get deliveries_url
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET /show" do
      it "redirects to the dashboard path" do
        get deliveries_url(delivery)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get deliveries_url(delivery)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "POST /close" do
      it "redirects to the dashboard path" do
        post close_delivery_url(delivery)
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        post close_delivery_url(delivery)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET /load_truck" do
      it "redirects to the dashboard path" do
        get load_truck_deliveries_url
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get load_truck_deliveries_url
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    describe "GET /start" do
      it "redirects to the dashboard path" do
        get start_deliveries_url
        expect(response).to redirect_to(dashboard_path)
      end

      it "renders the correct flash alert" do
        get start_deliveries_url
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
