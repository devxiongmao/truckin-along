class MakeCompanyOptionalInShipments < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:shipments, :company_id)
      change_column_null :shipments, :company_id, true
    end
  end

  def down
    if column_exists?(:shipments, :company_id)
      change_column_null :shipments, :company_id, false
    end
  end
end
