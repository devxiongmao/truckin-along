class AddCoordinatesToShipments < ActiveRecord::Migration[8.0]
  include MigrationHelpers::IdempotentMigration

  def up
    columns.each do |column|
      add_column_unless_exists :shipments, column, :float
    end
  end

  def down
    columns.each do |column|
      remove_column_if_exists :shipments, column
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
