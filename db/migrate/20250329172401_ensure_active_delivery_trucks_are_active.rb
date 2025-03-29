class EnsureActiveDeliveryTrucksAreActive < ActiveRecord::Migration[8.0]
  def up
    Truck.find_each do |truck|
      if !truck.active && !truck.available?
        truck.update(active: true)
      end
    end
  end

  def down
    Truck.find_each do |truck|
      if truck.active && !truck.available?
        truck.update(active: false)
      end
    end
  end
end
