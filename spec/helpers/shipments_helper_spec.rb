require 'rails_helper'

RSpec.describe ShipmentsHelper, type: :helper do
  let(:shipment) { create(:shipment, sender_name: "John Doe", sender_address: "123 Main St") }
  let(:customer) { create(:user, role: "customer", home_address: "456 Customer St") }
  let(:admin) { create(:user, role: "admin") }
  let(:driver) { create(:user, role: "driver") }
  let(:shipment_status_locked) { create(:shipment_status, locked_for_customers: true) }
  let(:shipment_status_unlocked) { create(:shipment_status, locked_for_customers: false) }
  let(:shipment_status_closed) { create(:shipment_status, closed: true) }


  describe "#auto_select_sender" do
    context "when the current user is a customer" do
      before { allow(helper).to receive(:current_user).and_return(customer) }

      it "returns the display_name of the customer" do
        expect(helper.auto_select_sender(shipment)).to eq("John Doe")
      end
    end

    context "when the current user is not a customer" do
      before { allow(helper).to receive(:current_user).and_return(admin) }

      it "returns the sender_name of the shipment" do
        expect(helper.auto_select_sender(shipment)).to eq("John Doe")
      end
    end

    context "when there is no current user" do
      before { allow(helper).to receive(:current_user).and_return(nil) }

      it "returns the sender_name of the shipment" do
        expect(helper.auto_select_sender(shipment)).to eq("John Doe")
      end
    end
  end

  describe "#auto_select_address" do
    context "when all conditions are met" do
      before { allow(helper).to receive(:current_user).and_return(customer) }

      it "returns the home_address of the customer" do
        shipment.sender_address = ""
        expect(helper.auto_select_address(shipment)).to eq("456 Customer St")
      end
    end

    context "when the current user is not a customer" do
      before { allow(helper).to receive(:current_user).and_return(admin) }

      it "returns the sender_address of the shipment" do
        expect(helper.auto_select_address(shipment)).to eq("123 Main St")
      end
    end

    context "when there is no current user" do
      before { allow(helper).to receive(:current_user).and_return(nil) }

      it "returns the sender_address of the shipment" do
        expect(helper.auto_select_address(shipment)).to eq("123 Main St")
      end
    end
  end

  describe "#locked_fields?" do
    context "when the status is closed" do
      it "returns true" do
        expect(helper.locked_fields?(shipment_status_closed)).to be_truthy
      end
    end

    context "when the current user is a customer" do
      context "when the shipment status is locked" do
        before { allow(helper).to receive(:current_user).and_return(customer) }

        it "returns true" do
            expect(helper.locked_fields?(shipment_status_locked)).to be_truthy
        end
      end

      context "when the shipment status is unlocked" do
        before { allow(helper).to receive(:current_user).and_return(customer) }

        it "returns false" do
            expect(helper.locked_fields?(shipment_status_unlocked)).to be_falsey
        end
      end
    end

    context "when the current user is not a customer" do
      before { allow(helper).to receive(:current_user).and_return(admin) }

      it "returns false regardless of shipment status" do
        expect(helper.locked_fields?(shipment_status_locked)).to be_falsey
        expect(helper.locked_fields?(shipment_status_unlocked)).to be_falsey
      end
    end

    context "when there is no current user" do
      before { allow(helper).to receive(:current_user).and_return(nil) }

      it "returns false" do
        expect(helper.locked_fields?(shipment_status_locked)).to be_falsey
        expect(helper.locked_fields?(shipment_status_unlocked)).to be_falsey
      end
    end
  end

  describe "#lock_fields_by_role" do
    context "when user is a customer" do
      before { allow(helper).to receive(:current_user).and_return(customer) }

      it "does not lock whitelisted fields for customers" do
        %i[name sender_name sender_address receiver_name receiver_address weight length width height].each do |field|
          expect(helper.lock_fields_by_role(field)).to eq(false)
        end
      end

      it "locks non-whitelisted fields for customers" do
        expect(helper.lock_fields_by_role(:shipment_status_id)).to eq(true)
        expect(helper.lock_fields_by_role(:truck_id)).to eq(true)
      end
    end

    context "when user is an admin" do
      before { allow(helper).to receive(:current_user).and_return(admin) }

      it "does not lock whitelisted fields for admins" do
        %i[shipment_status_id sender_address receiver_address weight length width height].each do |field|
          expect(helper.lock_fields_by_role(field)).to eq(false)
        end
      end

      it "locks non-whitelisted fields for admins" do
        expect(helper.lock_fields_by_role(:name)).to eq(true)
        expect(helper.lock_fields_by_role(:sender_name)).to eq(true)
        expect(helper.lock_fields_by_role(:receiver_name)).to eq(true)
      end
    end

    context "when user is a driver" do
      before { allow(helper).to receive(:current_user).and_return(driver) }

      it "does not lock whitelisted fields for drivers" do
        %i[shipment_status_id weight length width height].each do |field|
          expect(helper.lock_fields_by_role(field)).to eq(false)
        end
      end

      it "locks non-whitelisted fields for drivers" do
        expect(helper.lock_fields_by_role(:name)).to eq(true)
        expect(helper.lock_fields_by_role(:sender_name)).to eq(true)
        expect(helper.lock_fields_by_role(:sender_address)).to eq(true)
        expect(helper.lock_fields_by_role(:receiver_name)).to eq(true)
        expect(helper.lock_fields_by_role(:receiver_address)).to eq(true)
      end
    end
  end
end
