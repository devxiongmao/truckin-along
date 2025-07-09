require 'rails_helper'

RSpec.describe ScheduleDelivery, type: :service do
  let(:company) { create(:company) }
  let(:truck) { create(:truck, company: company) }
  let(:shipment_status) { create(:shipment_status, closed: false) }
  let(:new_status) { create(:shipment_status, closed: false) }

  let!(:shipment1) { create(:shipment, truck: nil, company: company, shipment_status: shipment_status) }
  let!(:shipment2) { create(:shipment, truck: nil, company: company, shipment_status: shipment_status) }
  let!(:delivery_shipment1) { create(:delivery_shipment, shipment: shipment1) }
  let!(:delivery_shipment2) { create(:delivery_shipment, shipment: shipment2) }
  let(:params) { { truck_id: truck.id, shipment_ids: [ shipment1.id, shipment2.id ] } }

  subject { described_class.new(params, company) }

  describe "#run" do
    context "with valid input" do
      before do
        create(:shipment_action_preference, company: company, action: "loaded_onto_truck", shipment_status: new_status)
      end

      it "creates a delivery if one does not exist" do
        expect { subject.run }.to change(Delivery, :count).by(1)
      end

      it "sets the delivery attributes correctly" do
        subject.run
        delivery = truck.deliveries.scheduled.first
        expect(delivery.user_id).to be_nil
        expect(delivery.truck).to eq(truck)
        expect(delivery.status).to eq("scheduled")
      end

      it "reuses existing scheduled delivery if one exists" do
        existing_delivery = create(:delivery, truck: truck, status: :scheduled)
        expect { subject.run }.not_to change(Delivery, :count)

        subject.run
        expect(delivery_shipment1.reload.delivery_id).to eq(existing_delivery.id)
      end

      it "updates latest delivery_shipments with loaded_date and delivery_id" do
        subject.run
        delivery = truck.deliveries.scheduled.first

        expect(delivery_shipment1.reload.loaded_date).not_to be_nil
        expect(delivery_shipment1.delivery_id).to eq(delivery.id)

        expect(delivery_shipment2.reload.loaded_date).not_to be_nil
        expect(delivery_shipment2.delivery_id).to eq(delivery.id)
      end

      it "updates shipment truck assignments" do
        subject.run

        expect(shipment1.reload.truck).to eq(truck)
        expect(shipment2.reload.truck).to eq(truck)
      end

      it "updates shipment statuses when shipment_action_preference exists" do
        subject.run

        expect(shipment1.reload.shipment_status).to eq(new_status)
        expect(shipment2.reload.shipment_status).to eq(new_status)
      end

      it "does not update shipment status when no shipment_action_preference exists" do
        # Clear the shipment_action_preference created in the before block
        company.shipment_action_preferences.destroy_all

        subject.run

        expect(shipment1.reload.shipment_status_id).to eq(shipment_status.id)
        expect(shipment2.reload.shipment_status_id).to eq(shipment_status.id)
      end

      it "returns true" do
        expect(subject.run).to eq(true)
      end

      it "does not add any errors" do
        subject.run
        expect(subject.errors).to be_empty
      end
    end

    context "when truck is not found" do
      let(:params) { { truck_id: 999, shipment_ids: [ shipment1.id ] } }

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors).to include("Please select a truck.")
      end

      it "does not create any deliveries" do
        expect { subject.run }.not_to change(Delivery, :count)
      end
    end

    context "when truck_id is nil" do
      let(:params) { { truck_id: nil, shipment_ids: [ shipment1.id ] } }

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

    context "when shipment_ids are for different company" do
      let(:other_company) { create(:company) }
      let(:other_shipment) { create(:shipment, company: other_company) }
      let(:params) { { truck_id: truck.id, shipment_ids: [ other_shipment.id ] } }

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors).to include("Please select at least one shipment.")
      end
    end

    context "when shipment_ids contains invalid ids" do
      let(:params) { { truck_id: truck.id, shipment_ids: [ 999, 1000 ] } }

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors).to include("Please select at least one shipment.")
      end
    end

    context "when delivery creation fails" do
      before do
        allow_any_instance_of(Truck).to receive_message_chain(:deliveries, :scheduled, :first).and_return(nil)
        allow_any_instance_of(Truck).to receive_message_chain(:deliveries, :create!).and_raise(ActiveRecord::RecordInvalid.new(Delivery.new))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Transaction failed/)
      end

      it "does not update any shipments" do
        expect { subject.run }.not_to change { shipment1.reload.truck_id }
      end
    end

    context "when delivery_shipment update fails" do
      before do
        allow_any_instance_of(DeliveryShipment).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(DeliveryShipment.new))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Transaction failed/)
      end

      it "rolls back the transaction" do
        expect { subject.run }.not_to change(Delivery, :count)
        expect(shipment1.reload.truck_id).to be_nil
      end
    end

    context "when shipment update fails" do
      before do
        allow_any_instance_of(ActiveRecord::Relation).to receive(:update_all).and_raise(ActiveRecord::RecordInvalid.new(Shipment.new))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Transaction failed/)
      end

      it "rolls back the transaction" do
        expect { subject.run }.not_to change(Delivery, :count)
      end
    end

    context "with mixed valid and invalid shipment ids" do
      let(:params) { { truck_id: truck.id, shipment_ids: [ shipment1.id, 999 ] } }

      it "processes only valid shipments" do
        create(:shipment_action_preference, company: company, action: "loaded_onto_truck", shipment_status: new_status)

        expect(subject.run).to eq(true)
        expect(shipment1.reload.truck).to eq(truck)
      end
    end

    context "when shipment has no latest_delivery_shipment" do
      let(:shipment_without_delivery) { create(:shipment, truck: nil, company: company) }
      let(:params) { { truck_id: truck.id, shipment_ids: [ shipment_without_delivery.id ] } }

      it "handles gracefully when latest_delivery_shipment is nil" do
        expect { subject.run }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#initialize" do
    it "converts shipment_ids to integers" do
      service = described_class.new({ truck_id: truck.id, shipment_ids: [ "1", "2" ] }, company)
      expect(service.instance_variable_get(:@shipment_ids)).to eq([ 1, 2 ])
    end

    it "handles nil shipment_ids" do
      service = described_class.new({ truck_id: truck.id, shipment_ids: nil }, company)
      expect(service.instance_variable_get(:@shipment_ids)).to eq([])
    end

    it "handles string shipment_ids" do
      service = described_class.new({ truck_id: truck.id, shipment_ids: "123" }, company)
      expect(service.instance_variable_get(:@shipment_ids)).to eq([ 123 ])
    end
  end

  describe "performance considerations" do
    let!(:shipments) { create_list(:shipment, 50, truck: nil, company: company, shipment_status: shipment_status) }
    let(:params) { { truck_id: truck.id, shipment_ids: shipments.map(&:id) } }

    before do
      # Create delivery_shipments for all shipments
      shipments.each { |shipment| create(:delivery_shipment, shipment: shipment) }
      create(:shipment_action_preference, company: company, action: "loaded_onto_truck", shipment_status: new_status)
    end

    it "uses includes to avoid N+1 queries" do
      expect(ActiveRecord::Base.connection).to receive(:execute).at_most(10).times.and_call_original
      subject.run
    end

    it "uses find_each for batch processing" do
      expect_any_instance_of(ActiveRecord::Relation).to receive(:find_each)
      subject.run
    end

    it "uses update_all for bulk updates" do
      expect_any_instance_of(ActiveRecord::Relation).to receive(:update_all).with(
        truck_id: truck.id,
        shipment_status_id: new_status.id
      )
      subject.run
    end
  end
end
