class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings, if_not_exists: true do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :stars, null: false # 1 to 5
      t.text :comment

      t.timestamps
    end
  end
end
