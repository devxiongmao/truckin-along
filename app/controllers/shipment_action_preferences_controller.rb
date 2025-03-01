class ShipmentActionPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_preference, only: %i[ edit update ]

  def new
    @preference = ShipmentActionPreference.new
  end
  
  def create
    @preference = current_company.shipment_action_preferences.find_or_initialize_by(
      action: params[:action_name]
    )
    @preference.shipment_status_id = params[:shipment_status_id]
    
    if @preference.save
      redirect_to admin_index_path, notice: 'Preference saved!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @statuses = current_user.role == "customer" ? [] : ShipmentStatus.for_company(current_company)
  end

  def update
    if @preference.update(preference_params)
      redirect_to admin_index_path, notice: "Preference was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def preference_params
      params.require(:shipment_action_preferences).premit(:action, :shipment_status_id)
    end

    def set_preference
      @preference = ShipmentActionPreference.find(params[:id])
    end
end