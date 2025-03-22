class AddDeliveryToForms < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:forms, :delivery_id)
      add_reference :forms, :delivery, foreign_key: true, null: true
    end
  end
end
