namespace :forms do
  desc "Backfill formable_type and formable_id with batching and logging"
  task backfill_formable: :environment do
    batch_size = 500
    total_updated = 0
    start_time = Time.current

    puts "[#{start_time}] Starting backfill of formable..."

    Form.find_in_batches(batch_size: batch_size) do |forms|
      Form.transaction do
        forms.each do |form|
          formable_type = nil
          formable_id = nil

          if form.delivery_id.present?
            formable_type = "Delivery"
            formable_id = form.delivery_id
          elsif form.truck_id.present?
            formable_type = "Truck"
            formable_id = form.truck_id
          end

          if formable_type && formable_id
            form.update_columns(formable_type: formable_type, formable_id: formable_id)
            total_updated += 1
          end
        end
      end

      puts "[#{Time.current}] Processed batch of #{forms.size}, total updated: #{total_updated}"
    end

    end_time = Time.current
    puts "[#{end_time}] Backfill complete! Total forms updated: #{total_updated} (Duration: #{end_time - start_time}s)"
  end
end
