require 'rails_helper'

RSpec.describe UpdateShipment do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:closed_status) { create(:shipment_status, company: company, closed: true) }
  let(:locked_status) { create(:shipment_status, company: company, locked_for_customers: true) }
  let(:delivery) { create(:delivery, user: user) }

  let(:shipment) do
    create(:shipment,
           user: user,
           company: company)
  end

  describe '#run' do
    context 'when shipment is closed' do
      before do
        shipment.update!(shipment_status: closed_status)
      end

      it 'returns failure with appropriate message' do
        service = described_class.new(shipment, { name: 'Updated Name' }, user)
        result = service.run

        expect(result.success?).to be false
        expect(result.error).to eq('Shipment is closed, and currently locked for edits.')
      end
    end

    context 'when shipment is locked for customers' do
      before do
        shipment.update!(shipment_status: locked_status)
      end

      it 'returns failure for customer users' do
        customer_user = create(:user, role: 'customer')
        service = described_class.new(shipment, { name: 'Updated Name' }, customer_user)
        result = service.run

        expect(result.success?).to be false
        expect(result.error).to eq('Shipment is currently locked for edits.')
      end

      it 'allows updates for non-customer users' do
        driver_user = create(:user, role: 'driver', company: company)
        service = described_class.new(shipment, { name: 'Updated Name' }, driver_user)
        result = service.run

        expect(result.success?).to be true
        expect(shipment.reload.name).to eq('Updated Name')
      end
    end

    context 'when status is updated to closed' do
      let!(:delivery_shipment) do
        create(:delivery_shipment,
               delivery: delivery,
               shipment: shipment)
      end

      it 'updates the delivered_date on the latest delivery shipment' do
        travel_to Time.current do
          service = described_class.new(shipment, { shipment_status_id: closed_status.id }, user)
          result = service.run

          expect(result.success?).to be true
          expect(shipment.reload.shipment_status_id).to eq(closed_status.id)
          expect(delivery_shipment.reload.delivered_date).to eq(Time.current)
        end
      end

      it 'does not update delivered_date when status is not changed' do
        # Update to closed status first
        shipment.update!(shipment_status: closed_status)
        original_delivered_date = delivery_shipment.delivered_date

        # Now try to update other fields without changing status
        service = described_class.new(shipment, { name: 'Updated Name' }, user)
        result = service.run

        expect(result.success?).to be false
        expect(result.error).to eq('Shipment is closed, and currently locked for edits.')
      end

      it 'does not update delivered_date when status is changed to non-closed' do
        new_status = create(:shipment_status, company: company, closed: false)
        original_delivered_date = delivery_shipment.delivered_date

        service = described_class.new(shipment, { shipment_status_id: new_status.id }, user)
        result = service.run

        expect(result.success?).to be true
        expect(shipment.reload.shipment_status_id).to eq(new_status.id)
        expect(delivery_shipment.reload.delivered_date).to eq(original_delivered_date)
      end
    end

    context 'when update is successful' do
      it 'returns success with appropriate message' do
        service = described_class.new(shipment, { name: 'Updated Name' }, user)
        result = service.run

        expect(result.success?).to be true
        expect(result.message).to eq('Shipment was successfully updated.')
        expect(shipment.reload.name).to eq('Updated Name')
      end
    end

    context 'when update fails validation' do
      it 'returns failure with validation errors' do
        service = described_class.new(shipment, { name: '' }, user)
        result = service.run

        expect(result.success?).to be false
        expect(result.error).to include("Name can't be blank")
      end
    end

    context 'when an exception occurs' do
      it 'returns failure with error message' do
        allow(shipment).to receive(:update).and_raise(StandardError.new('Database error'))

        service = described_class.new(shipment, { name: 'Updated Name' }, user)
        result = service.run

        expect(result.success?).to be false
        expect(result.error).to eq('An error occurred while updating the shipment: Database error')
      end
    end
  end
end
