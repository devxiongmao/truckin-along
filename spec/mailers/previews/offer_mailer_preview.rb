# Preview all emails at http://localhost:3000/rails/mailers/offer_mailer_mailer
class OfferMailerPreview < ActionMailer::Preview
  def offer_received
    company = FactoryBot.create(:company)
    admin = FactoryBot.create(:user, :admin, company: company)
    customer = FactoryBot.create(:user, :customer)
    shipment = FactoryBot.create(:shipment, user: customer, company: company, name: "Preview Shipment")
    offer = FactoryBot.create(:offer, shipment: shipment, company: company, price: 123.45, notes: "Special offer note")
    OfferMailer.offer_received(offer.id)
  end

  def offer_rejected
    company = FactoryBot.create(:company)
    admin = FactoryBot.create(:user, :admin, company: company)
    customer = FactoryBot.create(:user, :customer)
    shipment = FactoryBot.create(:shipment, user: customer, company: company, name: "Preview Shipment")
    offer = FactoryBot.create(:offer, :rejected, shipment: shipment, company: company, price: 123.45, notes: "Special offer note")
    OfferMailer.offer_rejected(offer.id)
  end

  def offer_accepted
    company = FactoryBot.create(:company)
    admin = FactoryBot.create(:user, :admin, company: company)
    customer = FactoryBot.create(:user, :customer)
    shipment = FactoryBot.create(:shipment, user: customer, company: company, name: "Preview Shipment")
    offer = FactoryBot.create(:offer, :accepted, shipment: shipment, company: company, price: 123.45, notes: "Special offer note")
    OfferMailer.offer_accepted(offer.id)
  end
end
