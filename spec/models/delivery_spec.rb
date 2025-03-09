require 'rails_helper'

RSpec.describe Delivery, type: :model do
  # Define a valid truck object for reuse
  let(:valid_delivery) { create(:delivery) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:truck) }
    it { is_expected.to have_many(:delivery_shipments) }
    it { is_expected.to have_many(:shipments).through(:delivery_shipments) }
  end

  ## Enum Tests
  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(scheduled: 0, in_progress: 1, completed: 2, cancelled: 3) }
  end

  ## Validation Tests
  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
  end

  ## Default Value Tests
  describe "defaults" do
    it "defaults status to scheduled" do
      delivery = Delivery.new
      expect(delivery.status).to eq("scheduled")
    end
  end

  ## Scope Tests
  describe "scopes" do
    before do
      @scheduled_delivery = create(:delivery, status: :scheduled)
      @in_progress_delivery = create(:delivery, status: :in_progress)
      @completed_delivery = create(:delivery, status: :completed)
      @cancelled_delivery = create(:delivery, status: :cancelled)
    end

    describe ".active" do
      it "includes scheduled and in_progress deliveries" do
        expect(Delivery.active).to include(@scheduled_delivery, @in_progress_delivery)
        expect(Delivery.active).not_to include(@completed_delivery, @cancelled_delivery)
      end
    end

    describe ".inactive" do
      it "includes completed and cancelled deliveries" do
        expect(Delivery.inactive).to include(@completed_delivery, @cancelled_delivery)
        expect(Delivery.inactive).not_to include(@scheduled_delivery, @in_progress_delivery)
      end
    end
  end

  ## Instance Method Tests
  describe "#active?" do
    it "returns true for scheduled deliveries" do
      delivery = build(:delivery, status: :scheduled)
      expect(delivery.active?).to be true
    end

    it "returns true for in_progress deliveries" do
      delivery = build(:delivery, status: :in_progress)
      expect(delivery.active?).to be true
    end

    it "returns false for completed deliveries" do
      delivery = build(:delivery, status: :completed)
      expect(delivery.active?).to be false
    end

    it "returns false for cancelled deliveries" do
      delivery = build(:delivery, status: :cancelled)
      expect(delivery.active?).to be false
    end
  end

  describe "#can_be_closed?" do
    let!(:delivery) { create(:delivery) }
    let!(:status) { create(:shipment_status, closed: true) }
    let!(:shipment1) { create(:shipment, shipment_status: status) }


    context "when all shipments are closed" do
      let!(:shipment2) { create(:shipment, shipment_status: status) }
      let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery, shipment: shipment1) }
      let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery, shipment: shipment2) }

      it "returns true" do
        expect(delivery.can_be_closed?).to be(true)
      end
    end

    context "when shipments are open" do
      let!(:open_status) { create(:shipment_status, closed: false) }
      let!(:shipment2) { create(:shipment, shipment_status: open_status) }
      let!(:delivery_shipment1) { create(:delivery_shipment, delivery: delivery, shipment: shipment1) }
      let!(:delivery_shipment2) { create(:delivery_shipment, delivery: delivery, shipment: shipment2) }

      it "returns false" do
        expect(delivery.can_be_closed?).to be(false)
      end
    end

    context "when there are no shipments" do
      it "returns true" do
        expect(delivery.can_be_closed?).to be(true)
      end
    end
  end
end
