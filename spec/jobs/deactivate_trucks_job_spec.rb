require 'rails_helper'

RSpec.describe DeactivateTrucksJob, type: :job do
  let!(:truck_active) { create(:truck, active: true, mileage: 100_000) }
  let!(:truck_recent_inspection) do
    create(:truck, active: true, mileage: 110_000).tap do |truck|
      create(:form, :maintenance,
             truck: truck,
             custom_content: { "last_inspection_date" => 2.months.ago, "mileage" => 100_000 })
    end
  end
  let!(:truck_old_inspection) do
    create(:truck, active: true, mileage: 150_000).tap do |truck|
      create(:form, :maintenance,
             truck: truck,
             custom_content: { "last_inspection_date" => 7.months.ago, "mileage" => 125_000 })
    end
  end
  let!(:truck_high_mileage) do
    create(:truck, active: true, mileage: 130_000).tap do |truck|
      create(:form, :maintenance,
             truck: truck,
             custom_content: { "last_inspection_date" => 3.months.ago, "mileage" => 100_000 })
    end
  end
  let!(:truck_no_inspection) { create(:truck, active: true, mileage: 140_000) }

  describe "#perform" do
    it "deactivates trucks with no maintenance forms" do
      expect { described_class.perform_now }
        .to change { truck_no_inspection.reload.active }.from(true).to(false)
    end

    it "does not deactivate trucks with recent inspections and valid mileage" do
      expect { described_class.perform_now }
        .not_to change { truck_recent_inspection.reload.active }
    end

    it "deactivates trucks with old inspections" do
      expect { described_class.perform_now }
        .to change { truck_old_inspection.reload.active }.from(true).to(false)
    end

    it "deactivates trucks that exceeded mileage threshold since last inspection" do
      expect { described_class.perform_now }
        .to change { truck_high_mileage.reload.active }.from(true).to(false)
    end
  end

  describe "Job Enqueueing" do
    it "enqueues the job" do
      expect { described_class.perform_later }.to have_enqueued_job(DeactivateTrucksJob)
    end
  end
end
