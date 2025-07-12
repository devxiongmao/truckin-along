require 'rails_helper'

RSpec.describe "Ratings", type: :request do
  let(:company) { create(:company) }
  let(:customer) { create(:user, :customer, company: company) }
  let(:driver) { create(:user, :driver, company: company) }
  let(:admin) { create(:user, :admin, company: company) }
  let(:delivery_shipment) { create(:delivery_shipment) }

  describe "POST /ratings" do
    let(:valid_attributes) do
      {
        rating: {
          stars: 5,
          comment: "Excellent service!",
          company_id: company.id,
          user_id: customer.id,
          delivery_shipment_id: delivery_shipment.id
        }
      }
    end

    let(:invalid_attributes) do
      {
        rating: {
          stars: 6,
          comment: "",
          delivery_shipment_id: delivery_shipment.id
        }
      }
    end

    context "when user is a customer" do
      before do
        sign_in customer, scope: :user
      end

      context "with valid parameters" do
        it "creates a new rating" do
          expect {
            post ratings_path, params: valid_attributes
          }.to change(Rating, :count).by(1)
        end

        it "creates a rating with the correct attributes" do
          post ratings_path, params: valid_attributes

          rating = Rating.last
          expect(rating.stars).to eq(5)
          expect(rating.comment).to eq("Excellent service!")
          expect(rating.user).to eq(customer)
          expect(rating.company).to eq(company)
        end

        it "redirects to shipment show with success notice" do
          post ratings_path, params: valid_attributes

          expect(response).to redirect_to(shipment_path(delivery_shipment.shipment))
          expect(flash[:notice]).to eq("Rating was successfully submitted! Thank you.")
        end

        it "updates the company's average rating" do
          expect {
            post ratings_path, params: valid_attributes
          }.to change { company.reload.average_rating }
        end

        it "increments the company's ratings count" do
          expect {
            post ratings_path, params: valid_attributes
          }.to change { company.reload.ratings_count }.by(1)
        end
      end

      context "with invalid parameters" do
        it "does not create a new rating" do
          expect {
            post ratings_path, params: invalid_attributes
          }.not_to change(Rating, :count)
        end

        it "redirects to shipment show page with error alert" do
          post ratings_path, params: invalid_attributes

          expect(response).to redirect_to(shipment_path(delivery_shipment.shipment))
          expect(flash[:alert]).to eq("Something went wrong, please try again.")
        end
      end
    end

    context "when user is a driver" do
      before do
        sign_in driver, scope: :user
      end

      it "does not create a new rating" do
        expect {
          post ratings_path, params: valid_attributes
        }.not_to change(Rating, :count)
      end

      it "redirects to the dashboard path with error alert" do
        post ratings_path, params: valid_attributes

        expect(response).to redirect_to(dashboard_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when user is an admin" do
      before do
        sign_in admin, scope: :user
      end

      it "does not create a new rating" do
        expect {
          post ratings_path, params: valid_attributes
        }.not_to change(Rating, :count)
      end

      it "redirects to the dashboard with error alert" do
        post ratings_path, params: valid_attributes

        expect(response).to redirect_to(dashboard_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in page" do
        post ratings_path, params: valid_attributes

        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not create a new rating" do
        expect {
          post ratings_path, params: valid_attributes
        }.not_to change(Rating, :count)
      end
    end
  end
end
