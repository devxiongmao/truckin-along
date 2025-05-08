# Preview all emails at http://localhost:3000/rails/mailers/shipment_delivery_mailer
class ShipmentDeliveryMailerPreview < ActionMailer::Preview
  def successfully_delivered_email
    shipment = Shipment.first || FactoryBot.create(:shipment)

    ShipmentDeliveryMailer.successfully_delivered_email(shipment.id)
  end
end
