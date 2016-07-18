json.array!(@queue_items) do |item|
  json.extract! item, :service_id, :created_at
  json.team item.team.name
end
