require "ostruct"
class CloseDelivery < ApplicationService
  def initialize(delivery, params)
    @delivery = delivery
    @odometer_reading = params[:odometer_reading].to_i
  end

  def call
    return failure("Delivery still has open shipments. It cannot be closed at this time.") unless @delivery.can_be_closed?
    return failure("Odometer reading must be higher than previous value. Please revise.") unless valid_odometer_reading?

    ActiveRecord::Base.transaction do
      update_truck_mileage
      deactivate_truck_if_needed
      complete_delivery
    end

    success("Delivery complete!")
  rescue => e
    failure("An error occurred while closing the delivery: #{e.message}")
  end

  private

  def valid_odometer_reading?
    @odometer_reading > @delivery.truck.mileage
  end

  def update_truck_mileage
    @delivery.truck.update!(mileage: @odometer_reading)
  end

  def deactivate_truck_if_needed
    if @delivery.truck.should_deactivate?
      @delivery.truck.deactivate!
      TruckMailer.send_truck_maintenance_due_email(@delivery.truck.id).deliver_later
    end
  end

  def complete_delivery
    @delivery.update!(status: :completed)
  end

  def success(message)
    OpenStruct.new(success?: true, message: message)
  end

  def failure(error)
    OpenStruct.new(success?: false, error: error)
  end
end
