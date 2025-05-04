class ScheduleDelivery < ApplicationService
  attr_reader :errors

  def initialize(params, company)
    @truck_id = params[:truck_id]
    @shipment_ids = params[:shipment_ids]
    @current_company = company
    @errors = []
  end

  def run
    success = false

    ActiveRecord::Base.transaction do
      truck = Truck.find(@truck_id)
      unless truck.present?
        @errors << "Please select a truck."
        raise ActiveRecord::Rollback
      end

      find_delivery(truck)
      shipments = find_shipments
      if shipments.empty?
        @errors << "Please select at least one shipment."
        raise ActiveRecord::Rollback
      end

      create_delivery_shipments(shipments)
      load_shipments(shipments)

      success = true
    end

    success
  end

  private

  def find_delivery(truck)
    @delivery = truck.deliveries.scheduled.first
    return if @delivery.present?
    @delivery = Delivery.create!({
      user_id: nil,
      truck_id: @truck_id,
      status: :scheduled
    })
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to create delivery: #{e.message}"
    raise ActiveRecord::Rollback
  end

  def find_shipments
    Shipment.for_company(@current_company).where(id: @shipment_ids)
  end

  def create_delivery_shipments(shipments)
    shipments.each do |shipment|
      @delivery.delivery_shipments.create!({
        shipment: shipment,
        sender_address: shipment.sender_address,
        receiver_address: shipment.receiver_address
      })
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to associate shipment: #{e.message}"
    raise ActiveRecord::Rollback
  end

  def load_shipments(shipments)
    preference = @current_company.shipment_action_preferences.find_by(action: "loaded_onto_truck")
    if preference&.shipment_status_id
      shipments.each do |shipment|
        shipment.update!(shipment_status_id: preference.shipment_status_id)
      end
    end
    shipments.update_all(truck_id: @truck_id)
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to update shipment: #{e.message}"
    raise ActiveRecord::Rollback
  end
end
