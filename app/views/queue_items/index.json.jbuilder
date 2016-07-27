json.array!(@queue_items) do |item|
  json.extract! item, :service_id, :created_at
end
