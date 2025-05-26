class DeactivateTrucksJob < ApplicationJob
  queue_as :default

  def perform
    Truck.where(active: true).find_each do |truck|
      next unless truck.should_deactivate? # Skip if not eligible

      begin
        truck.update!(active: false) # Use update! to raise an error if it fails
        Rails.logger.info("✅ Truck ##{truck.id} deactivated successfully")
      rescue StandardError => e
        Rails.logger.error("❌ Failed to deactivate Truck ##{truck.id}: #{e.message}")
      end
    end
  end
end
