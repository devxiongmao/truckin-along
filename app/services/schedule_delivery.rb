class ScheduleDelivery < ApplicationService
  attr_reader :errors

  def initialize(params, company)
    @truck_id = params[:truck_id]
    @shipment_ids = Array(params[:shipment_ids]).map(&:to_i)
    @current_company = company
    @errors = []
  end

  def run
    return add_error("Please select a truck.") unless valid_truck?

    shipments = find_shipments
    return add_error("Please select at least one shipment.") if shipments.empty?

    ActiveRecord::Base.transaction do
      @delivery = find_or_create_delivery
      update_delivery_shipments(shipments)
      load_shipments(shipments)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    add_error("Transaction failed: #{e.message}")
    false
  end

  private

  def valid_truck?
    @truck ||= Truck.find_by(id: @truck_id)
    @truck.present?
  end

  def find_or_create_delivery
    delivery = @truck.deliveries.scheduled.first
    return delivery if delivery.present?

    @truck.deliveries.create!(
      user_id: nil,
      status: :scheduled
    )
  end

  def find_shipments
    @current_company.shipments.where(id: @shipment_ids)
  end

  def update_delivery_shipments(shipments)
    shipments.includes(:delivery_shipments).find_each do |shipment|
      latest_delivery_shipment = shipment.latest_delivery_shipment

      latest_delivery_shipment.update!(
        loaded_date: Time.current,
        delivery_id: @delivery.id
      )
    end
  end


  def load_shipments(shipments)
    loaded_status_id = find_loaded_status_id

    update_params = { truck_id: @truck_id }
    update_params[:shipment_status_id] = loaded_status_id if loaded_status_id.present?

    shipments.update_all(update_params)
  end

  def find_loaded_status_id
    @current_company
      .shipment_action_preferences
      .find_by(action: "loaded_onto_truck")
      &.shipment_status_id
  end

  def add_error(message)
    @errors << message
    false
  end
end
