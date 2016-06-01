json.array!(@queue_items) do |item|
  json.extract! item, :line, :label, :time_in_queue
end
