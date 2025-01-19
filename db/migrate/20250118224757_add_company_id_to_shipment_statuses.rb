class AddCompanyIdToShipmentStatuses < ActiveRecord::Migration[8.0]
  def change
    add_reference :shipment_statuses, :company, null: false, foreign_key: true
  end
end
