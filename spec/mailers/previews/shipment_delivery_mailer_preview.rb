# Preview all emails at http://localhost:3000/rails/mailers/shipment_delivery_mailer
class ShipmentDeliveryMailerPreview < ActionMailer::Preview
  def successfully_delivered_email
    user = User.first || FactoryBot.create(:user, email: 'preview@example.com')
    shipment = Shipment.first || FactoryBot.create(:shipment)

    ShipmentDeliveryMailer.successfully_delivered_email(user.id, shipment.id)
  end
end
