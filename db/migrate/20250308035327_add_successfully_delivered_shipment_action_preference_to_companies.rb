class AddSuccessfullyDeliveredShipmentActionPreferenceToCompanies < ActiveRecord::Migration[8.0]
  def up
    Company.find_each do |company|
      ShipmentActionPreference.find_or_create_by!(
        action: "successfully_delivered",
        company_id: company.id,
        shipment_status: nil
      )
    end
  end

  def down
    ShipmentActionPreference.where(action: "successfully_delivered", shipment_status: nil).delete_all
  end
end
