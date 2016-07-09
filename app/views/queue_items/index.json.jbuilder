json.array!(@queue_items) do |item|
  json.extract! item, :line, :label, :created_at
end
