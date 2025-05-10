class ChangeFormReferencesToPolymorphic < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:forms, :formable_type) && column_exists?(:forms, :formable_id)
      add_reference :forms, :formable, polymorphic: true, index: true
    end
  end
end
