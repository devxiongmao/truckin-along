class AddCompanyIdToTrucks < ActiveRecord::Migration[8.0]
  def change
    add_reference :trucks, :company, null: false, foreign_key: true
  end
end
