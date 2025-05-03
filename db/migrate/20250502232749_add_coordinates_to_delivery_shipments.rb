class AddCoordinatesToDeliveryShipments < ActiveRecord::Migration[8.0]
  include MigrationHelpers::IdempotentMigration

  def up
    add_column_unless_exists :delivery_shipments, :sender_address, :text
    add_column_unless_exists :delivery_shipments, :receiver_address, :text

    columns.each do |column|
      add_column_unless_exists :delivery_shipments, column, :float
    end
  end

  def down
    remove_column_if_exists :delivery_shipments, :sender_address
    remove_column_if_exists :delivery_shipments, :receiver_address

    columns.each do |column|
      remove_column_if_exists :delivery_shipments, column
    end
  end

  private

  def columns
    %i[
      sender_latitude
      sender_longitude
      receiver_latitude
      receiver_longitude
    ]
  end
end
