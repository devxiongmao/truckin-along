require "ostruct"

class UpdateShipment < ApplicationService
  def initialize(shipment, params, current_user)
    @shipment = shipment
    @params = params
    @current_user = current_user
  end

  def run
    return failure("Shipment is closed, and currently locked for edits.") if shipment_closed?
    return failure("Shipment is currently locked for edits.") if shipment_locked_for_customer?

    previous_status_id = @shipment.shipment_status_id
    if @shipment.update(@params)
      maybe_update_delivered_date(previous_status_id)
      success("Shipment was successfully updated.")
    else
      failure(@shipment.errors.full_messages.join(", "))
    end
  rescue => e
    failure("An error occurred while updating the shipment: #{e.message}")
  end

  private

  def shipment_closed?
    @shipment.shipment_status&.closed
  end

  def shipment_locked_for_customer?
    @current_user.customer? && @shipment.shipment_status&.locked_for_customers
  end

  def maybe_update_delivered_date(previous_status_id)
    new_status_id = @params[:shipment_status_id]
    return unless new_status_id.present? && new_status_id.to_i != previous_status_id.to_i

    new_status = ShipmentStatus.find_by(id: new_status_id)
    if new_status&.closed
      @shipment.latest_delivery_shipment&.update!(delivered_date: Time.now)
    end
  end

  def success(message)
    OpenStruct.new(success?: true, message: message)
  end

  def failure(error)
    OpenStruct.new(success?: false, error: error)
  end
end
