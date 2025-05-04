require 'rails_helper'

RSpec.describe InitiateDelivery, type: :service do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:truck) { create(:truck, company: company) }
  let(:open_status) { create(:shipment_status, closed: false) }
  let(:new_status) { create(:shipment_status, closed: true) }

  let!(:shipment1) { create(:shipment, truck: truck, company: company, shipment_status: open_status) }
  let!(:shipment2) { create(:shipment, truck: truck, company: company, shipment_status: open_status) }

  let!(:preference) { create(:shipment_action_preference, company: company, action: "out_for_delivery", shipment_status: new_status) }

  let!(:delivery) { create(:delivery, truck: truck, status: :scheduled) }

  let(:params) { { truck_id: truck.id } }
  subject { described_class.new(params, user, company) }

  describe "#run" do
    context "with valid inputs" do
      it "returns true" do
        expect(subject.run).to be true
      end

      it "updates the delivery" do
        subject.run
        expect(delivery.reload.status).to eq("in_progress")
        expect(delivery.user_id).to eq(user.id)
      end

      it "creates a pre-delivery inspection form" do
        expect { subject.run }.to change(Form, :count).by(1)
        expect(Form.last.form_type).to eq("Pre-delivery Inspection")
      end

      it "updates shipment statuses" do
        subject.run
        expect(shipment1.reload.shipment_status_id).to eq(new_status.id)
        expect(shipment2.reload.shipment_status_id).to eq(new_status.id)
      end
    end

    context "when there are no open shipments" do
      before do
        shipment1.update!(shipment_status: new_status)
        shipment2.update!(shipment_status: new_status)
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors).to include("No open shipments found for this truck")
      end
    end

    context "when updating delivery fails" do
      before do
        allow_any_instance_of(Delivery).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(delivery))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Failed to create delivery/)
      end
    end

    context "when form creation fails" do
      before do
        allow(Form).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Form.new))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Failed to create Pre delivery inspection form/)
      end
    end

    context "when shipment status update fails" do
      before do
        allow_any_instance_of(Shipment).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(Shipment.new))
      end

      it "returns false and adds an error" do
        expect(subject.run).to eq(false)
        expect(subject.errors.first).to match(/Failed to update shipment status/)
      end
    end
  end
end
