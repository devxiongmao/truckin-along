require 'rails_helper'

RSpec.describe "/offers", type: :request do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }

  let(:customer) { create(:user, :customer) }
  let(:driver) { create(:user, :driver, company: company) }
  let(:admin) { create(:user, :admin, company: company) }
  let(:other_driver) { create(:user, :driver, company: other_company) }

  let(:customer_shipment) { create(:shipment, user: customer) }
  let(:driver_shipment) { create(:shipment, user: driver) }
  let(:other_customer_shipment) { create(:shipment, user: customer) }

  let!(:customer_offer) { create(:offer, shipment: customer_shipment, company: company, status: :issued) }
  let!(:driver_offer) { create(:offer, shipment: driver_shipment, company: company, status: :issued) }
  let!(:other_company_offer) { create(:offer, shipment: other_customer_shipment, company: other_company, status: :issued) }
  let!(:accepted_offer) { create(:offer, shipment: customer_shipment, company: company, status: :accepted) }
  let!(:rejected_offer) { create(:offer, shipment: customer_shipment, company: company, status: :rejected) }

  let(:valid_bulk_attributes) do
    {
      offers: [
        {
          shipment_id: customer_shipment.id,
          company_id: company.id,
          reception_address: "123 Main St",
          pickup_from_sender: false,
          deliver_to_door: true,
          dropoff_location: "456 Oak Ave",
          pickup_at_dropoff: false,
          price: 150.00,
          notes: "Test offer 1"
        },
        {
          shipment_id: customer_shipment.id,
          company_id: company.id,
          reception_address: "789 Pine St",
          pickup_from_sender: true,
          deliver_to_door: false,
          dropoff_location: "321 Elm St",
          pickup_at_dropoff: true,
          price: 200.00,
          notes: "Test offer 2"
        }
      ]
    }
  end

  let(:invalid_bulk_attributes) do
    {
      offers: [
        {
          shipment_id: customer_shipment.id,
          company_id: company.id,
          reception_address: "123 Main St",
          pickup_from_sender: false,
          deliver_to_door: true,
          dropoff_location: "456 Oak Ave",
          pickup_at_dropoff: false,
          price: nil, # Invalid - price is required
          notes: "Test offer 1"
        }
      ]
    }
  end

  describe "GET /index" do
    context "when user is not signed in" do
      it "redirects to the sign in page" do
        get offers_url
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is a customer" do
      before do
        sign_in customer, scope: :user
      end

      it "renders a successful response" do
        get offers_url
        expect(response).to be_successful
      end

      it "renders the index template" do
        get offers_url
        expect(response).to render_template(:index)
      end

      it "assigns @offers to issued offers for the customer's shipments" do
        get offers_url
        expect(assigns(:offers)).to include(customer_offer)
        expect(assigns(:offers)).to include(other_company_offer) # Same customer, different company
        expect(assigns(:offers)).not_to include(driver_offer) # Different customer
        expect(assigns(:offers)).not_to include(accepted_offer) # Not issued status
        expect(assigns(:offers)).not_to include(rejected_offer) # Not issued status
      end

      it "renders the customer offers partial" do
        get offers_url
        expect(response.body).to include("Shipment:")
        expect(response.body).to include("shipment-offers-section")
      end

      context "when customer has no issued offers" do
        before do
          Offer.update_all(status: :accepted) # Change all offers to accepted
        end

        it "shows empty state message" do
          get offers_url
          expect(response.body).to include("No offers available")
          expect(response.body).to include("You don't have any offers for your shipments yet")
          expect(response.body).to include("View My Shipments")
        end
      end
    end

    context "when user is a driver" do
      before do
        sign_in driver, scope: :user
      end

      it "renders a successful response" do
        get offers_url
        expect(response).to be_successful
      end

      it "renders the index template" do
        get offers_url
        expect(response).to render_template(:index)
      end

      it "assigns @offers to all offers for the driver's company" do
        get offers_url
        expect(assigns(:offers)).to include(customer_offer)
        expect(assigns(:offers)).to include(driver_offer)
        expect(assigns(:offers)).to include(accepted_offer)
        expect(assigns(:offers)).to include(rejected_offer)
        expect(assigns(:offers)).not_to include(other_company_offer)
      end

      it "renders the company offers partial" do
        get offers_url
        expect(response.body).to include("Create Bulk Offers")
        expect(response.body).to include("Shipment")
        expect(response.body).to include("Status")
      end

      context "when company has no offers" do
        before do
          Offer.destroy_all
        end

        it "shows empty state message" do
          get offers_url
          expect(response.body).to include("No offers found")
          expect(response.body).to include("Your company hasn't made any offers yet")
          expect(response.body).to include("View Available Shipments")
        end
      end
    end

    context "when user is an admin" do
      before do
        sign_in admin, scope: :user
      end

      it "renders a successful response" do
        get offers_url
        expect(response).to be_successful
      end

      it "renders the index template" do
        get offers_url
        expect(response).to render_template(:index)
      end

      it "assigns @offers to all offers for the admin's company" do
        get offers_url
        expect(assigns(:offers)).to include(customer_offer)
        expect(assigns(:offers)).to include(driver_offer)
        expect(assigns(:offers)).to include(accepted_offer)
        expect(assigns(:offers)).to include(rejected_offer)
        expect(assigns(:offers)).not_to include(other_company_offer)
      end

      it "renders the company offers partial" do
        get offers_url
        expect(response.body).to include("Create Bulk Offers")
        expect(response.body).to include("Shipment")
        expect(response.body).to include("Status")
      end
    end
  end

  describe "POST /bulk_create" do
    context "when user is not signed in" do
      it "redirects to the sign in page" do
        post bulk_create_offers_url, params: valid_bulk_attributes
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is a customer" do
      before do
        sign_in customer, scope: :user
      end

      it "redirects to dashboard path with error" do
        post bulk_create_offers_url, params: valid_bulk_attributes
        expect(response).to redirect_to(dashboard_path)
      end

      it "shows the error message" do
        post bulk_create_offers_url, params: valid_bulk_attributes
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end

      it "does not create any offers" do
        expect {
          post bulk_create_offers_url, params: valid_bulk_attributes
        }.not_to change(Offer, :count)
      end
    end

    context "when user is a driver" do
      before do
        sign_in driver, scope: :user
      end

      context "with valid parameters" do
        it "creates the expected number of offers" do
          expect {
            post bulk_create_offers_url, params: valid_bulk_attributes
          }.to change(Offer, :count).by(2)
        end

        it "sets the status to 'issued' for all created offers" do
          post bulk_create_offers_url, params: valid_bulk_attributes
          created_offers = Offer.last(2)
          expect(created_offers.map(&:status)).to all(eq("issued"))
        end

        it "redirects to offers index with success message" do
          post bulk_create_offers_url, params: valid_bulk_attributes
          expect(response).to redirect_to(offers_path)
          expect(flash[:notice]).to eq("2 offers were successfully created.")
        end

        it "creates offers with the correct attributes" do
          post bulk_create_offers_url, params: valid_bulk_attributes
          created_offers = Offer.last(2)

          first_offer = created_offers.first
          expect(first_offer.shipment_id).to eq(customer_shipment.id)
          expect(first_offer.company_id).to eq(company.id)
          expect(first_offer.reception_address).to eq("123 Main St")
          expect(first_offer.price).to eq(150.00)
          expect(first_offer.status).to eq("issued")

          second_offer = created_offers.last
          expect(second_offer.shipment_id).to eq(customer_shipment.id)
          expect(second_offer.company_id).to eq(company.id)
          expect(second_offer.reception_address).to eq("789 Pine St")
          expect(second_offer.price).to eq(200.00)
          expect(second_offer.status).to eq("issued")
        end
      end

      context "with invalid parameters" do
        it "does not create any offers" do
          expect {
            post bulk_create_offers_url, params: invalid_bulk_attributes
          }.not_to change(Offer, :count)
        end

        it "redirects to offers index with error message" do
          post bulk_create_offers_url, params: invalid_bulk_attributes
          expect(response).to redirect_to(offers_path)
          expect(flash[:alert]).to include("Errors occurred:")
          expect(flash[:alert]).to include("Price can't be blank")
        end
      end

      context "with empty offers array" do
        it "redirects to offers index with error message" do
          post bulk_create_offers_url, params: { offers: [] }
          expect(response).to redirect_to(offers_path)
          expect(flash[:alert]).to eq("No offers provided")
        end
      end
    end

    context "when user is an admin" do
      before do
        sign_in admin, scope: :user
      end

      context "with valid parameters" do
        it "creates the expected number of offers" do
          expect {
            post bulk_create_offers_url, params: valid_bulk_attributes
          }.to change(Offer, :count).by(2)
        end

        it "sets the status to 'issued' for all created offers" do
          post bulk_create_offers_url, params: valid_bulk_attributes
          created_offers = Offer.last(2)
          expect(created_offers.map(&:status)).to all(eq("issued"))
        end

        it "redirects to offers index with success message" do
          post bulk_create_offers_url, params: valid_bulk_attributes
          expect(response).to redirect_to(offers_path)
          expect(flash[:notice]).to eq("2 offers were successfully created.")
        end
      end

      context "with invalid parameters" do
        it "does not create any offers" do
          expect {
            post bulk_create_offers_url, params: invalid_bulk_attributes
          }.not_to change(Offer, :count)
        end

        it "redirects to offers index with error message" do
          post bulk_create_offers_url, params: invalid_bulk_attributes
          expect(response).to redirect_to(offers_path)
          expect(flash[:alert]).to include("Errors occurred:")
          expect(flash[:alert]).to include("Price can't be blank")
        end
      end
    end

    context "when database transaction fails" do
      before do
        sign_in driver, scope: :user
        allow(Offer).to receive(:transaction).and_raise(ActiveRecord::RecordInvalid.new(Offer.new))
      end

      it "redirects to offers index with error message" do
        post bulk_create_offers_url, params: valid_bulk_attributes
        expect(response).to redirect_to(offers_path)
        expect(flash[:alert]).to include("There was an error creating the offers:")
      end
    end
  end
end
