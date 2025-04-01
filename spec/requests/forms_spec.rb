require 'rails_helper'

RSpec.describe "Forms", type: :request do
  let(:company) { create(:company) } # Create a company

  let(:user) { create(:user, :admin, company: company) }
  let(:customer_user) { create(:user, :customer, company: company) }

  describe "when the user is an admin" do
    before do
      sign_in user, scope: :user
    end
    describe "GET /forms/:id/show_modal" do
      context "when form exists" do
        let(:form) { create(:form, :maintenance, company: company) }

        it "returns the correct partial" do
          get show_modal_form_path(form)

          expect(response).to be_successful
          expect(response).to render_template("forms/_completed_maintenance_form")
          expect(response).to have_http_status(:ok)
        end

        it "assigns the form to @form" do
          get show_modal_form_path(form)

          expect(assigns(:form)).to eq(form)
        end

        it "renders without layout" do
          get show_modal_form_path(form)

          expect(response).to render_template(layout: false)
        end
      end
    end
  end

  describe "when the user is a customer" do
    before do
      sign_in customer_user, scope: :user
    end

    describe "GET /forms/:id/show_modal" do
      context "when form exists" do
        let(:form) { create(:form, :maintenance, company: company) }

        it "redirects to the root path" do
          get show_modal_form_path(form)
          expect(response).to redirect_to(root_path)
        end

        it "renders an error message" do
          get show_modal_form_path(form)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end
      end
    end
  end
end
