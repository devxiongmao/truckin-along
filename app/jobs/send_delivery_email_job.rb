class SendDeliveryEmailJob < ApplicationJob
  queue_as :default

  def perform(shipment_id)
    ShipmentDeliveryMailer.successfully_delivered_email(shipment_id).deliver_now
  end
end
