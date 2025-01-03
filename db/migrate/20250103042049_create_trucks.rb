class CreateTrucks < ActiveRecord::Migration[8.0]
  def change
    create_table :trucks do |t|
      t.string :make
      t.string :model
      t.integer :year
      t.integer :mileage

      t.timestamps
    end
  end
end
