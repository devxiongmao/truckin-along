json.extract! shipment, :id, :name, :status, :sender_name, :sender_address, :receiver_name, :receiver_address, :weight, :boxes, :truck_id, :created_at, :updated_at
json.url shipment_url(shipment, format: :json)
