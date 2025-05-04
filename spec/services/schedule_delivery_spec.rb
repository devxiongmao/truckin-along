require 'rails_helper'

RSpec.describe ScheduleDelivery, type: :service do
  let(:company) { create(:company) }
  let(:truck) { create(:truck, company: company) }
  let(:shipment_status) { create(:shipment_status, closed: false) }
  let(:new_status) { create(:shipment_status, closed: false) }

  let!(:shipment1) { create(:shipment, truck: nil, company: company, shipment_status: shipment_status) }
  let!(:shipment2) { create(:shipment, truck: nil, company: company, shipment_status: shipment_status) }
  let!(:delivery_shipment) { create(:delivery_shipment, shipment: shipment2) }
  let(:params) { { truck_id: truck.id, delivery_address: "101 Animal Way, Florida, USA", shipment_ids: [ shipment1.id, shipment2.id ] } }

  subject { described_class.new(params, company) }

  describe "#run" do
    context "with valid input" do
      before do
        create(:shipment_action_preference, company: company, action: "loaded_onto_truck", shipment_status: new_status)
      end

      it "creates a delivery if one does not exist" do
        expect { subject.run }.to change(Delivery, :count).by(1)
      end

      it "reuses existing scheduled delivery if one exists" do
        create(:delivery, truck: truck, status: :scheduled)
        expect { subject.run }.not_to change(Delivery, :count)
      end

      it "associates shipments with the delivery" do
        subject.run
        delivery = truck.deliveries.scheduled.first
        expect(delivery.delivery_shipments.count).to eq(2)
      end

      it "updates shipment statuses and assigns truck" do
        subject.run
        expect(shipment1.reload.truck).to eq(truck)
        expect(shipment1.shipment_status).to eq(new_status)
      end

      it "updates delivery_shipments with the provided delivery address" do
        subject.run
        delivery = truck.deliveries.scheduled.first
        expect(delivery.delivery_shipments.first.receiver_address).to eq("101 Animal Way, Florida, USA")
      end

      it "updates delivery_shipments sender_address with the previous receiver_address" do
        subject.run
        delivery = truck.deliveries.scheduled.first
        expect(delivery.delivery_shipments.last.sender_address).to eq(delivery_shipment.receiver_address)
      end

      it "returns true" do
        expect(subject.run).to eq(true)
      end
    end

    context "when truck is not found" do
      let(:params) { { truck_id: 0, shipment_ids: [ shipment1.id ] } }

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors).to include("Please select a truck.")
      end
    end

    context "when no shipments are found" do
      let(:params) { { truck_id: truck.id, shipment_ids: [] } }

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors).to include("Please select at least one shipment.")
      end
    end

    context "when delivery creation fails" do
      before do
        allow(Delivery).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Delivery.new))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Failed to create delivery/)
      end
    end

    context "when shipment association fails" do
      before do
        allow_any_instance_of(Delivery).to receive(:delivery_shipments).and_raise(ActiveRecord::RecordInvalid.new(DeliveryShipment.new))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Failed to associate shipment/)
      end
    end

    context "when shipment update fails" do
      before do
        create(:shipment_action_preference, company: company, action: "loaded_onto_truck", shipment_status_id: new_status.id)
        allow_any_instance_of(Shipment).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(Shipment.new))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Failed to update shipment/)
      end
    end
  end
end
