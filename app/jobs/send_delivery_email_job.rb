class SendDeliveryEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id, shipment_id)
    ShipmentDeliveryMailer.successfully_delivered_email(user_id, shipment_id).deliver_now
  end
end
