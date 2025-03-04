class InitiateDelivery < ApplicationService
  def initialize(params, company)
    @truck_id = params[:truck_id]
    @current_company = company
  end

  def run
    create_delivery

    if @delivery.save
      shipments = Shipment.where(truck_id: params[:truck_id])
      open_shipments = shipments.select(&:open?)
      create_delivery_shipments(open_shipments)
      update_shipment_statuses(open_shipments)
      true
    else
      false
    end
  end

  def create_delivery
    @delivery = Delivery.new({
      user_id: current_user.id,
      truck_id: @truck_id,
      status: :in_progress
    })
  end

  def create_delivery_shipments(shipments)
    # Create DeliveryShipment records for each open shipment
    shipments.each do |shipment|
      @delivery.delivery_shipments.create!(shipment: shipment)
    end
  end

  def update_shipment_statuses(shipments)
    preference = @current_company.shipment_action_preferences.find_by(action: "out_for_delivery")
    if preference&.shipment_status_id
      shipments.update_all(shipment_status_id: preference.shipment_status_id)
    end
  end
end
