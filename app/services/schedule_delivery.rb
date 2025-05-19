class ScheduleDelivery < ApplicationService
  attr_reader :errors

  def initialize(params, company)
    @truck_id = params[:truck_id]
    @shipment_ids = Array(params[:shipment_ids]).map(&:to_i)
    @delivery_address = params[:delivery_address]
    @current_company = company
    @errors = []
  end


  def run
    return error("Please select a truck.") unless (truck = Truck.find_by(id: @truck_id))
    shipments = find_shipments
    return error("Please select at least one shipment.") if shipments.empty?

    ActiveRecord::Base.transaction do
      find_or_create_delivery(truck)
      create_delivery_shipments(shipments)
      load_shipments(shipments)
    end

    true
  rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid => e
    false
  end

  private

  def find_or_create_delivery(truck)
    @delivery = truck.deliveries.scheduled.first
    return if @delivery.present?
    @delivery = Delivery.create!({
      user_id: nil,
      truck_id: @truck_id,
      status: :scheduled
    })
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to create delivery: #{e.message}"
    raise e
  end

  def find_shipments
    Shipment.for_company(@current_company).where(id: @shipment_ids)
  end

  def create_delivery_shipments(shipments)
    shipment_attributes = shipments.map do |shipment|
      {
        delivery_id: @delivery.id,
        shipment_id: shipment.id,
        sender_address: set_sender_address(shipment),
        receiver_address: set_receiver_address(shipment),
        loaded_date: Time.now,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    @delivery.delivery_shipments.insert_all!(shipment_attributes)
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to associate shipment: #{e.message}"
    raise e
  end

  def set_sender_address(shipment)
    previous_delivery = shipment.latest_delivery_shipment
    return previous_delivery.receiver_address unless previous_delivery.nil?
    shipment.sender_address
  end

  def set_receiver_address(shipment)
    return @delivery_address if @delivery_address.present?
    shipment.receiver_address
  end

  def load_shipments(shipments)
    status_id = @current_company.shipment_action_preferences
                  .find_by(action: "loaded_onto_truck")
                  &.shipment_status_id

    shipments.each { |s| s.update!(shipment_status_id: status_id) if status_id }
    shipments.update_all(truck_id: @truck_id)
  rescue => e
    @errors << "Failed to update shipment: #{e.message}"
    raise e
  end

  def error(message)
    @errors << message
    false
  end
end
