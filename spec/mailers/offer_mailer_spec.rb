require "rails_helper"

RSpec.describe OfferMailer, type: :mailer do
  let(:company) { create(:company) }
  let(:admin) { create(:user, :admin, company: company) }
  let(:customer) { create(:user, :customer) }
  let(:shipment) { create(:shipment, user: customer, company: company) }
  let(:offer) { create(:offer, shipment: shipment, company: company, price: 123.45, notes: "Special offer note") }

  describe "offer_received" do
    subject(:mail) { described_class.offer_received(offer.id).deliver_now }

    it "sends to the shipment owner" do
      expect(mail.to).to eq([ shipment.user.email ])
    end

    it "has the correct subject" do
      expect(mail.subject).to include("received a new offer")
    end

    it "includes offer details in the body" do
      expect(mail.body.encoded).to include(offer.company.name)
      expect(mail.body.encoded).to include("$123.45")
      expect(mail.body.encoded).to include("Special offer note")
    end
  end

  describe "offer_rejected" do
    subject(:mail) { described_class.offer_rejected(offer.id).deliver_now }

    before { admin } # ensure admin exists for company

    it "sends to all company admins" do
      expect(mail.to).to match_array(company.admin_emails)
    end

    it "has the correct subject" do
      expect(mail.subject).to include("rejected")
    end

    it "includes offer details in the body" do
      expect(mail.body.encoded).to include(shipment.name)
      expect(mail.body.encoded).to include("$123.45")
      expect(mail.body.encoded).to include("Special offer note")
    end
  end

  describe "offer_accepted" do
    subject(:mail) { described_class.offer_accepted(offer.id).deliver_now }

    before { admin } # ensure admin exists for company

    it "sends to all company admins" do
      expect(mail.to).to match_array(company.admin_emails)
    end

    it "has the correct subject" do
      expect(mail.subject).to include("accepted")
    end

    it "includes offer details in the body" do
      expect(mail.body.encoded).to include(shipment.name)
      expect(mail.body.encoded).to include("$123.45")
      expect(mail.body.encoded).to include("Special offer note")
    end
  end
end
