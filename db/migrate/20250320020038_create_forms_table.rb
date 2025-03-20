class CreateFormsTable < ActiveRecord::Migration[8.0]
  def change
    create_table :forms, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.string :title, null: false
      t.string :form_type, null: false
      t.jsonb :content, default: {}, null: false
      t.datetime :submitted_at
      t.timestamps
    end
  end
end
