require 'rails_helper'

RSpec.describe ShipmentActionPreferencesHelper, type: :helper do
  describe '#action_explanation' do
    context 'with known actions' do
      it 'returns correct explanation for claimed_by_company' do
        expected = "This preference will be triggered when your company's bid for a shipment is accepted by the shipper."
        expect(helper.action_explanation('claimed_by_company')).to eq(expected)
      end

      it 'returns correct explanation for loaded_onto_truck' do
        expected = "This preference will be triggered when a shipment is loaded onto or assigned to a specific truck."
        expect(helper.action_explanation('loaded_onto_truck')).to eq(expected)
      end

      it 'returns correct explanation for out_for_delivery' do
        expected = "This preference will be triggered when the delivery is initiated after filling out the truck inspection checklist. This will signify the shipment is out for delivery."
        expect(helper.action_explanation('out_for_delivery')).to eq(expected)
      end

      it 'returns correct explanation for successfully_delivered' do
        expected = "This preference will be triggered when users click the 'Quick Close' button for a shipment that's out for delivery. This is meant to signify the shipment has been delivered successfully."
        expect(helper.action_explanation('successfully_delivered')).to eq(expected)
      end
    end

    context 'with unknown or invalid actions' do
      it 'returns fallback message for unknown action' do
        expect(helper.action_explanation('unknown_action')).to eq('No explanation available for this action.')
      end

      it 'returns fallback message for nil action' do
        expect(helper.action_explanation(nil)).to eq('No explanation available for this action.')
      end

      it 'returns fallback message for empty string' do
        expect(helper.action_explanation('')).to eq('No explanation available for this action.')
      end
    end
  end
end
