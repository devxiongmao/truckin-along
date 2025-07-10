class AddRatingsColumnsToCompanies < ActiveRecord::Migration[8.0]
  include MigrationHelpers::IdempotentMigration

  def up
    add_column_unless_exists :companies, :average_rating, :float, default: 0.0, null: false
    add_column_unless_exists :companies, :ratings_count, :integer, default: 0, null: false
  end

  def down
    remove_column_if_exists :companies, :average_rating
    remove_column_if_exists :companies, :ratings_count
  end
end
