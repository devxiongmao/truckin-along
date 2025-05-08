class ShipmentDeliveryMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def successfully_delivered_email(user_id, shipment_id)
    @user = User.find(user_id)
    @shipment = Shipment.find(shipment_id)

    mail(to: @user.email, subject: "Your package has been delivered!")
  end
end
