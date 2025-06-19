require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe CloseDelivery, type: :service do
  let(:truck) { create(:truck, mileage: 10000) }
  let(:delivery) { create(:delivery, truck: truck) }
  let(:odometer_reading) { 10500 }
  let(:params) { { odometer_reading: odometer_reading } }

  subject(:service) { described_class.new(delivery, params) }
  subject(:result) { service.call }

  describe '#call' do
    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end

    context 'when delivery can be successfully closed' do
      before do
        allow(delivery).to receive(:can_be_closed?).and_return(true)
        allow(truck).to receive(:should_deactivate?).and_return(false)
      end

      it 'returns a successful result' do
        expect(result.success?).to be true
        expect(result.message).to eq("Delivery complete!")
      end

      it 'updates the truck mileage' do
        expect { result }.to change { truck.reload.mileage }.from(10000).to(10500)
      end

      it 'completes the delivery' do
        expect { result }.to change { delivery.reload.status }.to('completed')
      end

      it 'does not deactivate the truck when should_deactivate? returns false' do
        expect(truck).not_to receive(:deactivate!)
        result
      end

      context 'when truck should be deactivated' do
        before do
          allow(truck).to receive(:should_deactivate?).and_return(true)
        end

        it 'deactivates the truck' do
          expect(truck).to receive(:deactivate!)
          result
        end

        it 'sends a maintenance due email' do
          expect {
            result
          }.to have_enqueued_mail(TruckMailer, :send_truck_maintenance_due_email).with(truck)
        end
      end
    end

    context 'when delivery cannot be closed' do
      before do
        allow(delivery).to receive(:can_be_closed?).and_return(false)
      end

      it 'returns a failure result' do
        expect(result.success?).to be false
        expect(result.error).to eq("Delivery still has open shipments. It cannot be closed at this time.")
      end

      it 'does not update truck mileage' do
        expect { result }.not_to change { truck.reload.mileage }
      end

      it 'does not complete the delivery' do
        expect { result }.not_to change { delivery.reload.status }
      end

      it 'does not send any emails' do
        expect { result }.not_to have_enqueued_mail
      end
    end

    context 'when odometer reading is invalid' do
      before do
        allow(delivery).to receive(:can_be_closed?).and_return(true)
      end

      context 'when odometer reading is less than current truck mileage' do
        let(:odometer_reading) { 9500 }

        it 'returns a failure result' do
          expect(result.success?).to be false
          expect(result.error).to eq("Odometer reading must be higher than previous value. Please revise.")
        end

        it 'does not update truck mileage' do
          expect { result }.not_to change { truck.reload.mileage }
        end

        it 'does not complete the delivery' do
          expect { result }.not_to change { delivery.reload.status }
        end

        it 'does not send any emails' do
          expect { result }.not_to have_enqueued_mail
        end
      end

      context 'when odometer reading equals current truck mileage' do
        let(:odometer_reading) { 10000 }

        it 'returns a failure result' do
          expect(result.success?).to be false
          expect(result.error).to eq("Odometer reading must be higher than previous value. Please revise.")
        end
      end
    end

    context 'when an exception occurs during transaction' do
      before do
        allow(delivery).to receive(:can_be_closed?).and_return(true)
        allow(delivery.truck).to receive(:update!).and_raise(StandardError.new("Database error"))
      end

      it 'returns a failure result with error message' do
        expect(result.success?).to be false
        expect(result.error).to eq("An error occurred while closing the delivery: Database error")
      end

      it 'does not complete the delivery due to transaction rollback' do
        expect(delivery).not_to receive(:update!) # ensure not called at all
        result
      end
    end

    context 'when truck update fails' do
      before do
        allow(delivery).to receive(:can_be_closed?).and_return(true)
        allow(delivery.truck).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(truck))
      end

      it 'handles the exception and returns failure' do
        expect(result.success?).to be false
        expect(result.error).to start_with("An error occurred while closing the delivery:")
      end
    end

    context 'when delivery status update fails' do
      before do
        allow(delivery).to receive(:can_be_closed?).and_return(true)
        allow(delivery).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(delivery))
      end

      it 'handles the exception and returns failure' do
        expect(result.success?).to be false
        expect(result.error).to start_with("An error occurred while closing the delivery:")
      end

      it 'rolls back truck mileage update due to transaction' do
        original_mileage = truck.mileage
        result
        expect(truck.reload.mileage).to eq(original_mileage)
      end
    end

    context 'when truck deactivation fails' do
      before do
        allow(delivery).to receive(:can_be_closed?).and_return(true)
        allow(delivery.truck).to receive(:should_deactivate?).and_return(true)
        allow(delivery.truck).to receive(:deactivate!).and_raise(StandardError.new("Deactivation failed"))
      end

      it 'handles the exception and returns failure' do
        expect(result.success?).to be false
        expect(result.error).to eq("An error occurred while closing the delivery: Deactivation failed")
      end

      it 'rolls back all changes due to transaction' do
        original_mileage = truck.mileage
        original_status = delivery.status
        result
        expect(delivery.truck.reload.mileage).to eq(original_mileage)
        expect(delivery.reload.status).to eq(original_status)
      end
    end
  end

  describe '#initialize' do
    it 'sets delivery and odometer_reading instance variables' do
      service = described_class.new(delivery, params)
      expect(service.instance_variable_get(:@delivery)).to eq(delivery)
      expect(service.instance_variable_get(:@odometer_reading)).to eq(odometer_reading)
    end
  end

  describe 'private methods' do
    describe '#valid_odometer_reading?' do
      it 'returns true when odometer reading is greater than truck mileage' do
        expect(service.send(:valid_odometer_reading?)).to be true
      end

      it 'returns false when odometer reading is less than truck mileage' do
        service.instance_variable_set(:@odometer_reading, 9500)
        expect(service.send(:valid_odometer_reading?)).to be false
      end

      it 'returns false when odometer reading equals truck mileage' do
        service.instance_variable_set(:@odometer_reading, 10000)
        expect(service.send(:valid_odometer_reading?)).to be false
      end
    end

    describe '#success' do
      it 'returns an OpenStruct with success? true and message' do
        result = service.send(:success, "Test message")
        expect(result.success?).to be true
        expect(result.message).to eq("Test message")
      end
    end

    describe '#failure' do
      it 'returns an OpenStruct with success? false and error' do
        result = service.send(:failure, "Test error")
        expect(result.success?).to be false
        expect(result.error).to eq("Test error")
      end
    end
  end

  # Integration-style tests to ensure the full flow works
  describe 'integration scenarios' do
    context 'complete successful delivery closure' do
      before do
        allow(delivery).to receive(:can_be_closed?).and_return(true)
        allow(truck).to receive(:should_deactivate?).and_return(true)
      end

      it 'performs all operations in correct order' do
        expect(truck).to receive(:update!).with(mileage: odometer_reading).ordered
        expect(truck).to receive(:deactivate!).ordered
        expect(delivery).to receive(:update!).with(status: :completed).ordered

        result
      end
    end

    context 'with edge case odometer readings' do
      let(:truck) { create(:truck, mileage: 0) }
      let(:odometer_reading) { 1 }

      before do
        allow(delivery).to receive(:can_be_closed?).and_return(true)
      end

      it 'handles very small positive differences' do
        expect(result.success?).to be true
        expect(truck.reload.mileage).to eq(1)
      end
    end
  end
end
