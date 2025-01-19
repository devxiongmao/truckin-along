class DeliveriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @unassigned_shipments = Shipment.for_company(current_company).where(user_id: nil)
    @my_shipments = Shipment.for_company(current_company).where(user: current_user)
  end
end
