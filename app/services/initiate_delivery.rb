class InitiateDelivery < ApplicationService
  attr_reader :delivery, :errors

  def initialize(params, current_user, company)
    @truck_id = params[:truck_id]
    @current_user = current_user
    @current_company = company
    @errors = []
  end

  def run
    success = false
    return error("Please select a truck.") unless (truck = Truck.find_by(id: @truck_id))

    ActiveRecord::Base.transaction do
      update_delivery(truck)
      create_delivery_form
      open_shipments = find_open_shipments

      if open_shipments.empty?
        @errors << "No open shipments found for this truck"
        raise ActiveRecord::Rollback
      end
      update_shipment_statuses(open_shipments)
      success = true
    end

    success
  end

  private

  def create_delivery_form
    @form = Form.create!({
      user_id: @current_user.id,
      company_id: @current_company.id,
      title: "Pre Delivery Inspection",
      form_type: "Pre-delivery Inspection",
      submitted_at: Time.now,
      formable_type: "Delivery",
      formable_id: @delivery.id,
      content: {
        start_time: Time.now
      }
    })
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to create Pre delivery inspection form: #{e.message}"
    raise ActiveRecord::Rollback
  end

  def update_delivery(truck)
    @delivery = truck.deliveries.scheduled.first
    @delivery.update!({
      user_id: @current_user.id,
      status: :in_progress
    })
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to create delivery: #{e.message}"
    raise ActiveRecord::Rollback
  end

  def find_open_shipments
    shipments = Shipment.where(truck_id: @truck_id, company_id: @current_company.id)
    shipments.select(&:open?)
  end

  def update_shipment_statuses(shipments)
    preference = @current_company.shipment_action_preferences.find_by(action: "out_for_delivery")

    if preference&.shipment_status_id
      shipments.each do |shipment|
        shipment.update!(shipment_status_id: preference.shipment_status_id)
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to update shipment status: #{e.message}"
    raise ActiveRecord::Rollback
  end

  def error(message)
    @errors << message
    false
  end
end
