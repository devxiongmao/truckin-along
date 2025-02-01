class AddHomeAddressToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :home_address, :string unless column_exists?(:users, :home_address)
  end

  def down
    remove_column :users, :home_address if column_exists?(:users, :home_address)
  end
end
