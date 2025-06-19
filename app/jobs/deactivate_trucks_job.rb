class DeactivateTrucksJob < ApplicationJob
  queue_as :default

  def perform
    Truck.where(active: true).find_each do |truck|
      next unless truck.should_deactivate? # Skip if not eligible

      begin
        truck.update!(active: false) # Use update! to raise an error if it fails
        TruckMailer.send_truck_maintenance_due_email(truck).deliver_later
        Rails.logger.info("✅ Truck ##{truck.id} deactivated successfully")
      rescue StandardError => e
        Rails.logger.error("❌ Failed to deactivate Truck ##{truck.id}: #{e.message}")
      end
    end
  end
end
