require 'rails_helper'

RSpec.describe InitiateDelivery, type: :service do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:truck) { create(:truck, company: company) }
  let(:open_status) { create(:shipment_status, closed: false) }
  let(:new_status) { create(:shipment_status, closed: true) }
  let(:closed_status) { create(:shipment_status, closed: true) }

  let(:shipment1) { create(:shipment, truck: truck, company: company, shipment_status: open_status) }
  let(:shipment2) { create(:shipment, truck: truck, company: company, shipment_status: open_status) }
  let(:closed_shipment) { create(:shipment, truck: truck, company: company, shipment_status: closed_status) }
  let(:params) { { truck_id: truck.id } }

  subject { described_class.new(params, user, company) }

  describe "#run" do
    context "when there are open shipments" do
      before do
        shipment1
        shipment2
      end

      it "creates a delivery" do
        expect { subject.run }.to change(Delivery, :count).by(1)
      end

      it "creates a form" do
        expect { subject.run }.to change(Form, :count).by(1)
      end

      it "associates shipments with the delivery" do
        subject.run
        expect(subject.delivery.shipments).to match_array([ shipment1, shipment2 ])
      end

      it "updates the shipment statuses" do
        preference = create(:shipment_action_preference, company: company, action: "out_for_delivery", shipment_status_id: new_status.id)
        subject.run
        expect(shipment1.reload.shipment_status_id).to eq(new_status.id)
        expect(shipment2.reload.shipment_status_id).to eq(new_status.id)
      end
    end

    context "when there are no open shipments" do
      it "does not create a delivery and returns an error" do
        expect { subject.run }.not_to change(Delivery, :count)
        expect(subject.errors).to include("No open shipments found for this truck")
      end
    end

    context "when delivery creation fails" do
      before do
        allow(Delivery).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Delivery.new))
      end

      it "does not proceed with shipment associations" do
        expect { subject.run }.not_to change(DeliveryShipment, :count)
      end

      it "adds an error message" do
        subject.run
        expect(subject.errors).to include(/Failed to create delivery/)
      end
    end

    context "when associating shipments fails" do
      before do
        shipment1
        shipment2
      end
      let(:delivery_shipments_double) { double('delivery_shipments') }

      before do
        allow_any_instance_of(Delivery).to receive(:delivery_shipments).and_return(delivery_shipments_double)
        allow(delivery_shipments_double).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(DeliveryShipment.new))
      end


      it "does not update shipment statuses" do
        expect { subject.run }.not_to change { shipment1.reload.shipment_status_id }
      end

      it "adds an error message" do
        subject.run
        expect(subject.errors).to include(/Failed to associate shipment/)
      end
    end
  end
end
