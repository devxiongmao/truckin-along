class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @drivers = User.for_company(current_company).drivers
    @shipment_statuses = ShipmentStatus.for_company(current_company)
    @trucks = Truck.for_company(current_company)
    @preferences = current_company.shipment_action_preferences
  end
end
