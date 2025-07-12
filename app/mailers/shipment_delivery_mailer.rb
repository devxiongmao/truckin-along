class ShipmentDeliveryMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def partially_delivered_email(shipment_id)
    @shipment = Shipment.find(shipment_id)
    @user = @shipment.user
    mail(to: @user.email, subject: "Your package has been delivered a partial distance!")
  end

  def successfully_delivered_email(shipment_id)
    @shipment = Shipment.find(shipment_id)
    @user = @shipment.user
    mail(to: @user.email, subject: "Your package has been delivered!")
  end
end
