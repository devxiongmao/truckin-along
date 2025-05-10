class RemoveLegacyColumnsFromForms < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:forms, :truck_id)
      remove_reference :forms, :truck, foreign_key: true
    end

    if column_exists?(:forms, :delivery_id)
      remove_reference :forms, :delivery, foreign_key: true
    end
  end

  def down
    unless column_exists?(:forms, :truck_id)
      add_reference :forms, :truck, foreign_key: true, null: true
    end

    unless column_exists?(:forms, :delivery_id)
      add_reference :forms, :delivery, foreign_key: true, null: true
    end
  end
end
