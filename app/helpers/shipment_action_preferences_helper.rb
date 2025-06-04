module ShipmentActionPreferencesHelper
  def action_explanation(action)
    explanations = {
      "claimed_by_company" => "This preference will be triggered when your company's bid for a shipment is accepted by the shipper.",
      "loaded_onto_truck" => "This preference will be triggered when a shipment is loaded onto or assigned to a specific truck.",
      "out_for_delivery" => "This preference will be triggered when the delivery is initiated after filling out the truck inspection checklist. This will signify the shipment is out for delivery.",
      "successfully_delivered" => "This preference will be triggered when users click the 'Quick Close' button for a shipment that's out for delivery. This is meant to signify the shipment has been delivered successfully."
    }

    explanations[action] || "No explanation available for this action."
  end
end
