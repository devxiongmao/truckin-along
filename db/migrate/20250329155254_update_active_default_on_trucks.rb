class UpdateActiveDefaultOnTrucks < ActiveRecord::Migration[8.0]
  def up
    connection = ActiveRecord::Base.connection
    default_value = connection.columns('trucks').find { |c| c.name == 'active' }&.default
    
    # Only change if the default is true (could be 't', '1', 'true' or true depending on your database)
    if default_value.to_s.downcase == 't' || default_value.to_s == '1' || default_value == true || default_value == 'true'
      change_column_default :trucks, :active, false
    end
  end

  def down
    change_column_default :trucks, :active, true
  end
end
