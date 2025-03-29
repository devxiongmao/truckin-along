class DeactivateTrucksJob < ApplicationJob
  queue_as :default

  def perform
    Truck.where(active: true).find_each do |truck|
      if should_deactivate?(truck)
        truck.update(active: false)
      end
    end
  end

  private

  def should_deactivate?(truck)
    last_form = truck.forms
                     .maintenance_forms
                     .order(Arel.sql("(forms.content->>'last_inspection_date')::date DESC")).first

    return true if last_form.nil?
    return true if last_form.content["last_inspection_date"] < 6.months.ago # Trucks must be inspected every 6 months
    return true if truck.mileage - last_form.content["mileage"] >= 25_000
    false
  end
end
