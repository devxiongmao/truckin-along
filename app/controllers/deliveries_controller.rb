class DeliveriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @unassigned_shipments = Shipment.where(user_id: nil)
    @my_shipments = Shipment.where(user: current_user)
  end
end
