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

  # New shipments specifically for bulk_create tests to avoid conflicts
  let(:bulk_test_shipment_1) { create(:shipment, user: customer) }
  let(:bulk_test_shipment_2) { create(:shipment, user: customer) }

  let!(:customer_offer) { create(:offer, shipment: customer_shipment, company: company, status: :issued) }
  let!(:driver_offer) { create(:offer, shipment: driver_shipment, company: company, status: :issued) }
  let!(:other_company_offer) { create(:offer, shipment: other_customer_shipment, company: other_company, status: :issued) }
  let!(:accepted_offer) { create(:offer, shipment: customer_shipment, company: company, status: :accepted) }
  let!(:rejected_offer) { create(:offer, shipment: customer_shipment, company: company, status: :rejected) }

  let(:valid_bulk_attributes) do
    {
      bulk_offer: {
        offers_attributes: {
          "0" => {
            shipment_id: bulk_test_shipment_1.id,
            reception_address: "123 Main St",
            pickup_from_sender: false,
            deliver_to_door: true,
            dropoff_location: "456 Oak Ave",
            pickup_at_dropoff: false,
            price: 150.00,
            notes: "Test offer 1"
          },
          "1" => {
            shipment_id: bulk_test_shipment_2.id,
            reception_address: "789 Pine St",
            pickup_from_sender: true,
            deliver_to_door: false,
            dropoff_location: "321 Elm St",
            pickup_at_dropoff: true,
            price: 200.00,
            notes: "Test offer 2"
          }
        }
      }
    }
  end

  let(:invalid_bulk_attributes) do
    {
      bulk_offer: {
        offers_attributes: {
          "0" => {
            shipment_id: customer_shipment.id,
            reception_address: "123 Main St",
            pickup_from_sender: false,
            deliver_to_door: true,
            dropoff_location: "456 Oak Ave",
            pickup_at_dropoff: false,
            price: nil, # Invalid - price is required
            notes: "Test offer 1"
          }
        }
      }
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

      it "redirects to offers path" do
        post bulk_create_offers_url, params: valid_bulk_attributes
        expect(response).to redirect_to(offers_path)
      end

      it "shows the authorization error message" do
        post bulk_create_offers_url, params: valid_bulk_attributes
        expect(flash[:alert]).to include("Not authorized to create this offer")
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
          expect(first_offer.shipment_id).to eq(bulk_test_shipment_1.id)
          expect(first_offer.company_id).to eq(company.id)
          expect(first_offer.reception_address).to eq("123 Main St")
          expect(first_offer.price).to eq(150.00)
          expect(first_offer.status).to eq("issued")

          second_offer = created_offers.last
          expect(second_offer.shipment_id).to eq(bulk_test_shipment_2.id)
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

        it "redirects to offers index" do
          post bulk_create_offers_url, params: invalid_bulk_attributes
          expect(response).to redirect_to(offers_path)
        end

        it "renders with error message" do
          post bulk_create_offers_url, params: invalid_bulk_attributes
          expect(flash[:alert]).to include("Errors occurred:")
          expect(flash[:alert]).to include("Price can't be blank")
        end
      end

      context "when trying to create duplicate active offers" do
        let!(:existing_offer) { create(:offer, shipment: bulk_test_shipment_1, company: company, status: :issued) }

        let(:duplicate_offer_attributes) do
          {
            bulk_offer: {
              offers_attributes: {
                "0" => {
                  shipment_id: bulk_test_shipment_1.id,
                  reception_address: "123 Main St",
                  pickup_from_sender: false,
                  deliver_to_door: true,
                  dropoff_location: "456 Oak Ave",
                  pickup_at_dropoff: false,
                  price: 150.00,
                  notes: "Test offer 1"
                }
              }
            }
          }
        end

        it "does not create any offers" do
          expect {
            post bulk_create_offers_url, params: duplicate_offer_attributes
          }.not_to change(Offer, :count)
        end

        it "redirects to offers index" do
          post bulk_create_offers_url, params: duplicate_offer_attributes
          expect(response).to redirect_to(offers_path)
        end

        it "shows the validation error message" do
          post bulk_create_offers_url, params: duplicate_offer_attributes
          expect(flash[:alert]).to include("You already have an active offer for this shipment")
        end

        context "when trying to create offers with different statuses" do
          let(:accepted_offer_attributes) do
            {
              bulk_offer: {
                offers_attributes: {
                  "0" => {
                    status: "accepted",
                    shipment_id: bulk_test_shipment_1.id,
                    reception_address: "123 Main St",
                    pickup_from_sender: false,
                    deliver_to_door: true,
                    dropoff_location: "456 Oak Ave",
                    pickup_at_dropoff: false,
                    price: 150.00,
                    notes: "Test offer 1"
                  }
                }
              }
            }
          end

          it "still prevents creation because controller sets status to issued" do
            expect {
              post bulk_create_offers_url, params: accepted_offer_attributes
            }.not_to change(Offer, :count)
          end

          it "shows validation error because controller sets status to issued" do
            post bulk_create_offers_url, params: accepted_offer_attributes
            expect(flash[:alert]).to include("You already have an active offer for this shipment")
          end

          it "redirects to the offers path" do
            post bulk_create_offers_url, params: accepted_offer_attributes
            expect(response).to redirect_to(offers_path)
          end
        end
      end

      context "with empty offers array" do
        it "redirects to offers index with error message" do
          post bulk_create_offers_url, params: { bulk_offer: { offers_attributes: {} } }
          expect(response).to redirect_to(offers_path)
          expect(flash[:alert]).to eq("No offers provided")
        end
      end

      context "with missing bulk_offer parameter" do
        it "redirects to offers index with error message" do
          post bulk_create_offers_url, params: {}
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

        it "creates offers with the correct company_id from current_company" do
          post bulk_create_offers_url, params: valid_bulk_attributes
          created_offers = Offer.last(2)
          expect(created_offers.map(&:company_id)).to all(eq(company.id))
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
        allow_any_instance_of(Offer).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Offer.new))
      end

      it "redirects to offers index with error message" do
        post bulk_create_offers_url, params: valid_bulk_attributes
        expect(response).to redirect_to(offers_path)
        expect(flash[:alert]).to include("There was an error creating the offers:")
      end
    end

    context "when authorization fails for some offers" do
      before do
        sign_in driver, scope: :user
        # Mock Pundit to raise NotAuthorizedError for the first offer
        allow_any_instance_of(OffersController).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it "does not create any offers" do
        expect {
          post bulk_create_offers_url, params: valid_bulk_attributes
        }.not_to change(Offer, :count)
      end

      it "redirects to offers index with authorization error message" do
        post bulk_create_offers_url, params: valid_bulk_attributes
        expect(response).to redirect_to(offers_path)
        expect(flash[:alert]).to include("Errors occurred:")
        expect(flash[:alert]).to include("Not authorized to create this offer")
      end
    end
  end

  describe "PATCH /accept" do
    let!(:accepted_offer) { create(:offer, shipment: customer_shipment, company: company, status: :accepted) }
    let!(:rejected_offer) { create(:offer, shipment: customer_shipment, company: company, status: :rejected) }
    let!(:withdrawn_offer) { create(:offer, shipment: customer_shipment, company: company, status: :withdrawn) }
    let!(:other_issued_offer) { create(:offer, shipment: customer_shipment, company: other_company, status: :issued) }

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        patch accept_offer_url(customer_offer)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is a customer" do
      before do
        sign_in customer, scope: :user
      end

      context "with an issued offer" do
        it "accepts the offer" do
          expect {
            patch accept_offer_url(customer_offer)
          }.to change { customer_offer.reload.status }.from("issued").to("accepted")
        end

        it "rejects all other issued offers for the same shipment" do
          expect {
            patch accept_offer_url(customer_offer)
          }.to change { other_issued_offer.reload.status }.from("issued").to("rejected")
        end

        it "redirects to offers path with success message" do
          patch accept_offer_url(customer_offer)
          expect(response).to redirect_to(offers_path)
          expect(flash[:notice]).to eq("Offer was successfully accepted. All other offers for this shipment have been rejected.")
        end

        it "does not affect offers with other statuses" do
          expect {
            patch accept_offer_url(customer_offer)
          }.not_to change { accepted_offer.reload.status }
          expect(accepted_offer.status).to eq("accepted")
        end

        it "does not affect offers for other shipments" do
          other_shipment_offer = create(:offer, shipment: other_customer_shipment, company: company, status: :issued)
          expect {
            patch accept_offer_url(customer_offer)
          }.not_to change { other_shipment_offer.reload.status }
          expect(other_shipment_offer.status).to eq("issued")
        end
      end

      context "with a non-issued offer" do
        it "does not accept the offer" do
          expect {
            patch accept_offer_url(accepted_offer)
          }.not_to change { accepted_offer.reload.status }
        end

        it "redirects to offers path with error message" do
          patch accept_offer_url(accepted_offer)
          expect(response).to redirect_to(offers_path)
          expect(flash[:alert]).to eq("Only issued offers can be accepted.")
        end

        it "does not reject other offers" do
          expect {
            patch accept_offer_url(accepted_offer)
          }.not_to change { other_issued_offer.reload.status }
        end
      end

      context "when offer belongs to another company" do
        it "accepts the offer if it's for the customer's shipment" do
          expect {
            patch accept_offer_url(other_company_offer)
          }.to change { other_company_offer.reload.status }.from("issued").to("accepted")
        end
      end
    end

    context "when user is a driver" do
      before do
        sign_in driver, scope: :user
      end

      it "does not accept the offer" do
        expect {
          patch accept_offer_url(customer_offer)
        }.not_to change { customer_offer.reload.status }
      end

      it "redirects to dashboard path" do
        patch accept_offer_url(customer_offer)
        expect(response).to redirect_to(dashboard_path)
      end

      it "shows authorization error" do
        patch accept_offer_url(customer_offer)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when user is an admin" do
      before do
        sign_in admin, scope: :user
      end

      it "does not accept the offer" do
        expect {
          patch accept_offer_url(customer_offer)
        }.not_to change { customer_offer.reload.status }
      end

      it "redirects to dashboard path" do
        patch accept_offer_url(customer_offer)
        expect(response).to redirect_to(dashboard_path)
      end

      it "shows authorization error" do
        patch accept_offer_url(customer_offer)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "PATCH /reject" do
    let!(:accepted_offer) { create(:offer, shipment: customer_shipment, company: company, status: :accepted) }
    let!(:rejected_offer) { create(:offer, shipment: customer_shipment, company: company, status: :rejected) }
    let!(:withdrawn_offer) { create(:offer, shipment: customer_shipment, company: company, status: :withdrawn) }

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        patch reject_offer_url(customer_offer)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is a customer" do
      before do
        sign_in customer, scope: :user
      end

      context "with an issued offer" do
        it "rejects the offer" do
          expect {
            patch reject_offer_url(customer_offer)
          }.to change { customer_offer.reload.status }.from("issued").to("rejected")
        end

        it "redirects to offers path with success message" do
          patch reject_offer_url(customer_offer)
          expect(response).to redirect_to(offers_path)
          expect(flash[:notice]).to eq("Offer was successfully rejected.")
        end

        it "does not affect other offers" do
          other_issued_offer = create(:offer, shipment: customer_shipment, company: other_company, status: :issued)
          expect {
            patch reject_offer_url(customer_offer)
          }.not_to change { other_issued_offer.reload.status }
          expect(other_issued_offer.status).to eq("issued")
        end
      end

      context "with a non-issued offer" do
        it "does not reject the offer" do
          expect {
            patch reject_offer_url(accepted_offer)
          }.not_to change { accepted_offer.reload.status }
        end

        it "redirects to offers path with error message" do
          patch reject_offer_url(accepted_offer)
          expect(response).to redirect_to(offers_path)
          expect(flash[:alert]).to eq("Only issued offers can be rejected.")
        end
      end

      context "when offer belongs to another company" do
        it "rejects the offer if it's for the customer's shipment" do
          expect {
            patch reject_offer_url(other_company_offer)
          }.to change { other_company_offer.reload.status }.from("issued").to("rejected")
        end
      end
    end

    context "when user is a driver" do
      before do
        sign_in driver, scope: :user
      end

      it "does not reject the offer" do
        expect {
          patch reject_offer_url(customer_offer)
        }.not_to change { customer_offer.reload.status }
      end

      it "redirects to dashboard path" do
        patch reject_offer_url(customer_offer)
        expect(response).to redirect_to(dashboard_path)
      end

      it "shows authorization error" do
        patch reject_offer_url(customer_offer)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when user is an admin" do
      before do
        sign_in admin, scope: :user
      end

      it "does not reject the offer" do
        expect {
          patch reject_offer_url(customer_offer)
        }.not_to change { customer_offer.reload.status }
      end

      it "redirects to dashboard path" do
        patch reject_offer_url(customer_offer)
        expect(response).to redirect_to(dashboard_path)
      end

      it "shows authorization error" do
        patch reject_offer_url(customer_offer)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "PATCH /withdraw" do
    let!(:accepted_offer) { create(:offer, shipment: customer_shipment, company: company, status: :accepted) }
    let!(:rejected_offer) { create(:offer, shipment: customer_shipment, company: company, status: :rejected) }
    let!(:withdrawn_offer) { create(:offer, shipment: customer_shipment, company: company, status: :withdrawn) }

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        patch withdraw_offer_url(customer_offer)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is a customer" do
      before do
        sign_in customer, scope: :user
      end

      it "does not withdraw the offer" do
        expect {
          patch withdraw_offer_url(customer_offer)
        }.not_to change { customer_offer.reload.status }
      end

      it "redirects to dashboard path" do
        patch withdraw_offer_url(customer_offer)
        expect(response).to redirect_to(dashboard_path)
      end

      it "shows authorization error" do
        patch withdraw_offer_url(customer_offer)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    context "when user is a driver" do
      before do
        sign_in driver, scope: :user
      end

      context "with an issued offer from the driver's company" do
        it "withdraws the offer" do
          expect {
            patch withdraw_offer_url(customer_offer)
          }.to change { customer_offer.reload.status }.from("issued").to("withdrawn")
        end

        it "redirects to offers path with success message" do
          patch withdraw_offer_url(customer_offer)
          expect(response).to redirect_to(offers_path)
          expect(flash[:notice]).to eq("Offer was successfully withdrawn.")
        end

        it "does not affect other offers" do
          other_issued_offer = create(:offer, shipment: customer_shipment, company: other_company, status: :issued)
          expect {
            patch withdraw_offer_url(customer_offer)
          }.not_to change { other_issued_offer.reload.status }
          expect(other_issued_offer.status).to eq("issued")
        end
      end

      context "with a non-issued offer" do
        it "does not withdraw the offer" do
          expect {
            patch withdraw_offer_url(accepted_offer)
          }.not_to change { accepted_offer.reload.status }
        end

        it "redirects to offers path with error message" do
          patch withdraw_offer_url(accepted_offer)
          expect(response).to redirect_to(offers_path)
          expect(flash[:alert]).to eq("Only issued offers can be withdrawn.")
        end
      end

      context "when offer belongs to another company" do
        it "does not withdraw the offer" do
          expect {
            patch withdraw_offer_url(other_company_offer)
          }.not_to change { other_company_offer.reload.status }
        end

        it "redirects to dashboard path" do
          patch withdraw_offer_url(other_company_offer)
          expect(response).to redirect_to(dashboard_path)
        end

        it "shows authorization error" do
          patch withdraw_offer_url(other_company_offer)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end

    context "when user is an admin" do
      before do
        sign_in admin, scope: :user
      end

      context "with an issued offer from the admin's company" do
        it "withdraws the offer" do
          expect {
            patch withdraw_offer_url(customer_offer)
          }.to change { customer_offer.reload.status }.from("issued").to("withdrawn")
        end

        it "redirects to offers path with success message" do
          patch withdraw_offer_url(customer_offer)
          expect(response).to redirect_to(offers_path)
          expect(flash[:notice]).to eq("Offer was successfully withdrawn.")
        end

        it "does not affect other offers" do
          other_issued_offer = create(:offer, shipment: customer_shipment, company: other_company, status: :issued)
          expect {
            patch withdraw_offer_url(customer_offer)
          }.not_to change { other_issued_offer.reload.status }
          expect(other_issued_offer.status).to eq("issued")
        end
      end

      context "with a non-issued offer" do
        it "does not withdraw the offer" do
          expect {
            patch withdraw_offer_url(accepted_offer)
          }.not_to change { accepted_offer.reload.status }
        end

        it "redirects to offers path with error message" do
          patch withdraw_offer_url(accepted_offer)
          expect(response).to redirect_to(offers_path)
          expect(flash[:alert]).to eq("Only issued offers can be withdrawn.")
        end
      end

      context "when offer belongs to another company" do
        it "does not withdraw the offer" do
          expect {
            patch withdraw_offer_url(other_company_offer)
          }.not_to change { other_company_offer.reload.status }
        end

        it "redirects to dashboard path" do
          patch withdraw_offer_url(other_company_offer)
          expect(response).to redirect_to(dashboard_path)
        end

        it "shows authorization error" do
          patch withdraw_offer_url(other_company_offer)
          expect(flash[:alert]).to eq("Not authorized.")
        end
      end
    end
  end
end
