class OfferMailer < ApplicationMailer
  # Notifies shipment owner that they've received a new offer
  def offer_received(offer_id)
    @offer = Offer.find_by(id: offer_id)
    @shipment = @offer.shipment
    mail(to: @shipment.user.email, subject: "You've received a new offer for your shipment")
  end

  # Notifies company admins that their offer was rejected
  def offer_rejected(offer_id)
    @offer = Offer.find_by(id: offer_id)
    @shipment = @offer.shipment
    mail(to: @offer.company.admin_emails, subject: "Your offer was rejected")
  end

  # Notifies company admins that their offer was accepted
  def offer_accepted(offer_id)
    @offer = Offer.find_by(id: offer_id)
    @shipment = @offer.shipment
    mail(to: @offer.company.admin_emails, subject: "Your offer was accepted!")
  end
end
