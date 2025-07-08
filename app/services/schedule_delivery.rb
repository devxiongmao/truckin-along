class ScheduleDelivery < ApplicationService
  attr_reader :errors

  def initialize(params, company)
    @truck_id = params[:truck_id]
    @shipment_ids = Array(params[:shipment_ids]).map(&:to_i)
    @current_company = company
    @errors = []
  end


  def run
    return error("Please select a truck.") unless (truck = Truck.find_by(id: @truck_id))
    shipments = find_shipments
    return error("Please select at least one shipment.") if shipments.empty?

    ActiveRecord::Base.transaction do
      find_or_create_delivery(truck)
      update_delivery_shipments(shipments)
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

  def update_delivery_shipments(shipments)
    shipments.each do |shipment|
      last_delivery_shipment = shipment.latest_delivery_shipment
      last_delivery_shipment.loaded_date = Time.now
      last_delivery_shipment.delivery_id = @delivery.id
      last_delivery_shipment.save!
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to associate shipment: #{e.message}"
    raise e
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
