require 'rails_helper'

RSpec.describe ShipmentsHelper, type: :helper do
  let(:shipment) { create(:shipment, sender_name: "John Doe", sender_address: "123 Main St") }
  let(:customer) { create(:user, role: "customer", home_address: "456 Customer St") }
  let(:admin) { create(:user, role: "admin") }
  let(:shipment_status_locked) { create(:shipment_status, locked_for_customers: true) }
  let(:shipment_status_unlocked) { create(:shipment_status, locked_for_customers: false) }

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
    context "when the current user is a customer" do
      before { allow(helper).to receive(:current_user).and_return(customer) }

      it "returns the home_address of the customer" do
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
    context "when the current user is a customer and the shipment status is locked" do
      before { allow(helper).to receive(:current_user).and_return(customer) }

      it "returns true" do
        expect(helper.locked_fields?(shipment_status_locked)).to be_truthy
      end
    end

    context "when the current user is a customer and the shipment status is unlocked" do
      before { allow(helper).to receive(:current_user).and_return(customer) }

      it "returns false" do
        expect(helper.locked_fields?(shipment_status_unlocked)).to be_falsey
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
end
