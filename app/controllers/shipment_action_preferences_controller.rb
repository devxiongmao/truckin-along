class ShipmentActionPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_preference

  def edit
    @shipment_statuses = ShipmentStatus.for_company(current_company)
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
      params.require(:shipment_action_preference).permit(:shipment_status_id, :company_id)
    end

    def set_preference
      @preference = ShipmentActionPreference.find(params[:id])
    end
end
