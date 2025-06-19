require 'rails_helper'

RSpec.describe DeactivateTrucksJob, type: :job do
  let!(:truck_active) { create(:truck, active: true, mileage: 100_000) }
  let!(:truck_recent_inspection) do
    create(:truck, active: true, mileage: 110_000).tap do |truck|
      create(:form, :maintenance,
             formable: truck,
             custom_content: { "last_inspection_date" => 2.months.ago, "mileage" => 100_000 })
    end
  end
  let!(:truck_old_inspection) do
    create(:truck, active: true, mileage: 150_000).tap do |truck|
      create(:form, :maintenance,
             formable: truck,
             custom_content: { "last_inspection_date" => 7.months.ago, "mileage" => 125_000 })
    end
  end
  let!(:truck_high_mileage) do
    create(:truck, active: true, mileage: 130_000).tap do |truck|
      create(:form, :maintenance,
             formable: truck,
             custom_content: { "last_inspection_date" => 3.months.ago, "mileage" => 100_000 })
    end
  end
  let!(:truck_no_inspection) { create(:truck, active: true, mileage: 140_000) }

  let!(:truck_inactive) { create(:truck, active: false, mileage: 160_000) }
  let!(:truck_unavailable) { create(:truck, active: true, mileage: 170_000) }
  let!(:active_delivery) { create(:delivery, truck_id: truck_unavailable.id) }

  let!(:truck_edge_case) do
    create(:truck, active: true, mileage: 125_000).tap do |truck|
      create(:form, :maintenance,
             formable: truck,
             custom_content: { "last_inspection_date" => 6.months.ago.to_date, "mileage" => 100_000 })
    end
  end
  let!(:truck_update_error) do
    create(:truck, active: true, mileage: 180_000)
  end

  describe "#perform" do
    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    it "deactivates trucks with no maintenance forms" do
      expect { described_class.perform_now }
        .to change { truck_no_inspection.reload.active }.from(true).to(false)

      expect(Rails.logger).to have_received(:info).with("✅ Truck ##{truck_no_inspection.id} deactivated successfully")
    end

    it "does not deactivate trucks with recent inspections and valid mileage" do
      expect { described_class.perform_now }
        .not_to change { truck_recent_inspection.reload.active }
    end

    it "deactivates trucks with old inspections" do
      expect { described_class.perform_now }
        .to change { truck_old_inspection.reload.active }.from(true).to(false)

      expect(Rails.logger).to have_received(:info).with("✅ Truck ##{truck_old_inspection.id} deactivated successfully")
    end

    it "deactivates trucks that exceeded mileage threshold since last inspection" do
      expect { described_class.perform_now }
        .to change { truck_high_mileage.reload.active }.from(true).to(false)

      expect(Rails.logger).to have_received(:info).with("✅ Truck ##{truck_high_mileage.id} deactivated successfully")
    end

    it "sends an email for trucks that have been deactivated" do
      expect { described_class.perform_now }
        .to have_enqueued_mail(TruckMailer, :send_truck_maintenance_due_email)
        .with(truck_old_inspection.id)
    end

    it "ignores already inactive trucks" do
      expect { described_class.perform_now }
        .not_to change { truck_inactive.reload.active }
    end

    it "skips trucks that are not available" do
      expect { described_class.perform_now }
        .not_to change { truck_unavailable.reload.active }
    end

    it "deactivates trucks exactly at the 6 month threshold" do
      expect { described_class.perform_now }
        .to change { truck_edge_case.reload.active }.from(true).to(false)
    end

    it "logs errors when update fails" do
      # Create a scenario where this specific truck should be deactivated
      create(:form, :maintenance,
             formable: truck_update_error,
             custom_content: { "last_inspection_date" => 7.months.ago, "mileage" => 150_000 })

      allow_any_instance_of(Truck).to receive(:update!).and_call_original
      allow_any_instance_of(Truck)
        .to receive(:update!)
        .with(active: false)
        .and_raise(ActiveRecord::RecordInvalid, truck_update_error)

      allow_any_instance_of(Truck).to receive(:update!).and_call_original
      allow_any_instance_of(Truck).to receive(:update!).with(active: false) do |truck|
        if truck.id == truck_update_error.id
          raise ActiveRecord::RecordInvalid.new(truck)
        else
          truck.send(:update_without_mock!, active: false)
        end
      end

      described_class.perform_now

      expect(Rails.logger).to have_received(:error).with(/Failed to deactivate Truck ##{truck_update_error.id}/)
    end
  end

  describe "Job Enqueueing" do
    it "enqueues the job" do
      expect { described_class.perform_later }.to have_enqueued_job(DeactivateTrucksJob)
    end

    it "enqueues to the default queue" do
      expect { described_class.perform_later }
        .to have_enqueued_job.on_queue('default')
    end
  end
end
