require 'rails_helper'

RSpec.describe Truck, type: :model do
  # Define a valid truck object for reuse
  let(:valid_truck) { create(:truck) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to have_many(:shipments) }
    it { is_expected.to have_many(:deliveries).dependent(:nullify) }
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:forms) }
  end

  ## Validation Tests
  describe "validations" do
    subject { valid_truck } # Use a valid truck as the baseline for testing

    # Uniqueness Validations
    it { is_expected.to validate_uniqueness_of(:vin) }

    # Presence Validations
    it { is_expected.to validate_presence_of(:make) }
    it { is_expected.to validate_presence_of(:model) }
    it { is_expected.to validate_presence_of(:length) }
    it { is_expected.to validate_presence_of(:width) }
    it { is_expected.to validate_presence_of(:height) }
    it { is_expected.to validate_presence_of(:weight) }
    it { is_expected.to validate_presence_of(:license_plate) }
    it { is_expected.to validate_presence_of(:vin) }

    # Numericality Validations
    it { is_expected.to validate_numericality_of(:length).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:width).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:height).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:weight).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:year).only_integer }
    it { is_expected.to validate_numericality_of(:year).is_greater_than_or_equal_to(1900) }
    it { is_expected.to validate_numericality_of(:mileage).only_integer }
    it { is_expected.to validate_numericality_of(:mileage).is_greater_than_or_equal_to(0) }

    it { is_expected.to validate_length_of(:vin).is_equal_to(17) }
  end

  ## Valid Truck Test
  describe "valid truck" do
    it "is valid with all required attributes" do
      expect(valid_truck).to be_valid
    end
  end

  ## Invalid Truck Tests
  describe "invalid truck" do
    it "is invalid without a make" do
      valid_truck.make = nil
      expect(valid_truck).not_to be_valid
    end

    it "is invalid without a model" do
      valid_truck.model = nil
      expect(valid_truck).not_to be_valid
    end

    it "is invalid with a year less than 1900" do
      valid_truck.year = 1899
      expect(valid_truck).not_to be_valid
    end

    it "is invalid with a negative mileage" do
      valid_truck.mileage = -1
      expect(valid_truck).not_to be_valid
    end
  end

  ## Edge Case Tests
  describe "edge cases" do
    it "allows mileage of zero" do
      valid_truck.mileage = 0
      expect(valid_truck).to be_valid
    end

    it "handles extremely large mileage values" do
      valid_truck.mileage = 1_000_000
      expect(valid_truck).to be_valid
    end

    it "does not allow non-integer values for year" do
      valid_truck.year = 2021.5
      expect(valid_truck).not_to be_valid
    end
  end

  ## Scope Tests
  describe "scopes" do
    let!(:company) { create(:company) }
    let!(:other_company) { create(:company) }

    let!(:truck) { create(:truck, company: company, active: true) }
    let!(:other_truck) { create(:truck, company: other_company, active: false) }

    describe ".for_company" do
      it "includes trucks that belong to the company" do
        expect(Truck.for_company(company)).to include(truck)
        expect(Truck.for_company(company)).not_to include(other_truck)
      end
    end

    describe ".active?" do
      it "includes trucks that active" do
        expect(Truck.active?).to include(truck)
        expect(Truck.active?).not_to include(other_truck)
      end
    end
  end

  ## Custom Method Tests
  describe "#display_name" do
    it "returns a string formatted as make-model-year" do
      expect(valid_truck.display_name).to eq("#{valid_truck.make}-#{valid_truck.model}-#{valid_truck.year}(#{valid_truck.license_plate})")
    end

    it "handles nil values gracefully" do
      valid_truck.make = nil
      valid_truck.model = nil
      valid_truck.year = nil
      valid_truck.license_plate = nil

      expect(valid_truck.display_name).to eq("--()")
    end
  end

  describe "#available?" do
    describe "when there is an active delivery" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }
      it "returns false" do
        expect(valid_truck.available?).to eq(false)
      end
    end

    describe "when there is not an active delivery" do
      it "returns true" do
        expect(valid_truck.available?).to eq(true)
      end
    end
  end

  describe "#active_delivery" do
    describe "when there is an active delivery" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }
      it "returns the delivery" do
        expect(valid_truck.active_delivery).to eq(delivery)
      end
    end

    describe "when there is not an active delivery" do
      it "returns nil" do
        expect(valid_truck.active_delivery).to be_nil
      end
    end
  end

  describe "#volume" do
    it "calculates the volume of the truck bed" do
      valid_truck.length = 13600
      valid_truck.height = 2800
      valid_truck.width = 2550
      expect(valid_truck.volume).to eq(97104000000)
    end
  end

  describe "#current_shipments" do
    context "when there are delivery shipments" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }

      let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery) }
      let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery) }
      it "returns the open shipments" do
        expect(valid_truck.current_shipments).to match_array([ delivery_shipment1.shipment, delivery_shipment2.shipment ])
      end
    end

    context "when there are no delivery shipments" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }
      it "returns an empty array" do
        expect(valid_truck.current_shipments).to eq([])
      end
    end

    context "when there is no delivery" do
      it "returns an empty array" do
        expect(valid_truck.current_shipments).to eq([])
      end
    end
  end

  describe "#earliest_due_date" do
    context "when there are shipments with different deliver_by dates" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }
      let!(:shipment1) { create(:shipment, deliver_by: 1.week.from_now.to_date) }
      let!(:shipment2) { create(:shipment, deliver_by: 2.weeks.from_now.to_date) }
      let!(:shipment3) { create(:shipment, deliver_by: 3.days.from_now.to_date) }

      let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery, shipment: shipment1) }
      let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery, shipment: shipment2) }
      let!(:delivery_shipment3) { create(:delivery_shipment, delivery: delivery, shipment: shipment3) }

      it "returns the earliest deliver_by date" do
        expect(valid_truck.earliest_due_date).to eq(3.days.from_now.to_date)
      end
    end

    context "when there are shipments with the same deliver_by date" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }
      let!(:shipment1) { create(:shipment, deliver_by: 1.week.from_now.to_date) }
      let!(:shipment2) { create(:shipment, deliver_by: 1.week.from_now.to_date) }

      let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery, shipment: shipment1) }
      let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery, shipment: shipment2) }

      it "returns the deliver_by date" do
        expect(valid_truck.earliest_due_date).to eq(1.week.from_now.to_date)
      end
    end

    context "when there are no delivery shipments" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }

      it "returns 'No shipments'" do
        expect(valid_truck.earliest_due_date).to eq("No shipments")
      end
    end

    context "when there is no delivery" do
      it "returns 'No shipments'" do
        expect(valid_truck.earliest_due_date).to eq("No shipments")
      end
    end
  end

  describe "#current_volume" do
    let!(:delivery) { create(:delivery, truck: valid_truck) }

    let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery) }
    let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery) }
    it "calculates the current volume of the truck bed" do
      expect(valid_truck.current_volume).to eq(delivery_shipment1.shipment.volume + delivery_shipment2.shipment.volume)
    end
  end

  describe "#current_weight" do
    let!(:delivery) { create(:delivery, truck: valid_truck) }

    let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery) }
    let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery) }
    it "calculates the current volume of the truck bed" do
      expect(valid_truck.current_weight).to eq(delivery_shipment1.shipment.weight + delivery_shipment2.shipment.weight)
    end
  end

  describe "#latest_delivery" do
    let!(:delivery) { create(:delivery, truck: valid_truck) }
    let!(:delivery2) { create(:delivery, truck: valid_truck, status: :completed) }

    it "returns the latest active delivery" do
      expect(valid_truck.latest_delivery).to eq(delivery)
    end
  end

  describe "#should_deactivate?" do
    context "when the truck has an active delivery" do
      let!(:delivery) { create(:delivery, truck: valid_truck) }

      it "returns false" do
        expect(valid_truck.should_deactivate?).to eq(false)
      end
    end

    context "when the truck has no maintenance forms" do
      let!(:truck_no_inspection) { create(:truck, active: true, mileage: 140_000) }

      it "returns true" do
        expect(truck_no_inspection.should_deactivate?).to eq(true)
      end
    end

    context "when a truck has an old inspection" do
      let!(:truck_old_inspection) do
        create(:truck, active: true, mileage: 150_000).tap do |truck|
          create(:form, :maintenance,
                formable: truck,
                custom_content: { "last_inspection_date" => 7.months.ago, "mileage" => 125_000 })
        end
      end

      it "returns true" do
        expect(truck_old_inspection.should_deactivate?).to eq(true)
      end
    end

    context "when the truck exceeds the mileage threshold" do
      let!(:truck_high_mileage) do
        create(:truck, active: true, mileage: 130_000).tap do |truck|
          create(:form, :maintenance,
                formable: truck,
                custom_content: { "last_inspection_date" => 3.months.ago, "mileage" => 100_000 })
        end
      end

      it "returns true" do
        expect(truck_high_mileage.should_deactivate?).to eq(true)
      end
    end

    context "when no conditions are met" do
      let!(:passing_truck) do
        create(:truck, active: true, mileage: 130_000).tap do |truck|
          create(:form, :maintenance,
                formable: truck,
                custom_content: { "last_inspection_date" => 3.months.ago, "mileage" => 120_000 })
        end
      end
      it "returns false" do
        expect(passing_truck.should_deactivate?).to eq(false)
      end
    end
  end

  describe "#deactivate!" do
    context "when the truck is active" do
      it "deactivates the truck" do
        valid_truck.deactivate!
        expect(valid_truck.active).to eq(false)
      end
    end
    context "when the truck is not active" do
      let(:invalid_truck) { create(:truck, active: false) }

      it "does not update the truck" do
        expect { invalid_truck.deactivate! }
          .not_to change { invalid_truck.reload.active }.from(false)
      end
    end
  end
end
