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

    ActiveRecord::Base.transaction do
      create_delivery_form
      create_delivery
      open_shipments = find_open_shipments

      if open_shipments.empty?
        @errors << "No open shipments found for this truck"
        raise ActiveRecord::Rollback
      end

      create_delivery_shipments(open_shipments)
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
      truck_id: @truck_id,
      title: "Pre Delivery Inspection",
      form_type: "Pre-delivery Inspection",
      content: {
        start_time: Time.now
      }
    })
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to create Pre delivery inspection form: #{e.message}"
    raise ActiveRecord::Rollback
  end

  def create_delivery
    @delivery = Delivery.create!({
      user_id: @current_user.id,
      truck_id: @truck_id,
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

  def create_delivery_shipments(shipments)
    shipments.each do |shipment|
      @delivery.delivery_shipments.create!(shipment: shipment)
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Failed to associate shipment: #{e.message}"
    raise ActiveRecord::Rollback
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
end
