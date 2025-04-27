require 'rails_helper'

RSpec.describe MigrationHelpers::IdempotentMigration do
  let(:dummy_class) do
    Class.new(ActiveRecord::Migration[8.0]) do
      include MigrationHelpers::IdempotentMigration
    end.new
  end

  before do
    # Create a dummy table
    ActiveRecord::Schema.define do
      create_table :dummy_shipments, force: true do |t|
        t.timestamps
      end
    end
  end

  after do
    # Clean up the dummy table
    ActiveRecord::Schema.define do
      drop_table :dummy_shipments, if_exists: true
    end
  end

  describe '#add_column_unless_exists' do
    it 'adds a new column if it does not exist' do
      expect {
        dummy_class.add_column_unless_exists(:dummy_shipments, :test_latitude, :float)
      }.to change {
        ActiveRecord::Base.connection.column_exists?(:dummy_shipments, :test_latitude)
      }.from(false).to(true)
    end

    it 'does not add the column if it already exists' do
      dummy_class.add_column_unless_exists(:dummy_shipments, :test_latitude, :float)

      expect {
        dummy_class.add_column_unless_exists(:dummy_shipments, :test_latitude, :float)
      }.not_to change {
        ActiveRecord::Base.connection.columns(:dummy_shipments).size
      }
    end
  end

  describe '#remove_column_if_exists' do
    it 'removes a column if it exists' do
      dummy_class.add_column_unless_exists(:dummy_shipments, :test_longitude, :float)

      expect {
        dummy_class.remove_column_if_exists(:dummy_shipments, :test_longitude)
      }.to change {
        ActiveRecord::Base.connection.column_exists?(:dummy_shipments, :test_longitude)
      }.from(true).to(false)
    end

    it 'does nothing if the column does not exist' do
      expect {
        dummy_class.remove_column_if_exists(:dummy_shipments, :non_existing_column)
      }.not_to raise_error
    end
  end
end
