require 'rails_helper'

RSpec.feature "Deliveries Index", type: :feature do
  let(:company) { create(:company) }

  let(:valid_user) { create(:user, company: company) }

  let!(:unassigned_shipment) { create(:shipment, company: nil) }
  let!(:assigned_shipment) { create(:shipment, company: company) }

  before do
    sign_in valid_user, scope: :user
  end

  scenario "displays unassigned shipments in the correct section" do
    visit deliveries_path

    within("#unassigned-shipments") do
      expect(page).to have_content(unassigned_shipment.name)
      expect(page).not_to have_content(assigned_shipment.name)
    end
  end

  scenario "displays user's shipments in the correct section" do
    visit deliveries_path

    within("#my-shipments") do
      expect(page).to have_content(assigned_shipment.name)
      expect(page).not_to have_content(unassigned_shipment.name)
    end
  end
end
