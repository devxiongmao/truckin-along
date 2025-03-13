class AdminController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize :admin, :index?
    @drivers = User.for_company(current_company).drivers
    @shipment_statuses = ShipmentStatus.for_company(current_company)
    @trucks = Truck.for_company(current_company)
    @preferences = current_company.shipment_action_preferences.order(:id)
  end
end
