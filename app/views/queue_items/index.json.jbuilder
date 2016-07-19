json.array!(@queue_items) do |item|
  json.created_at item.created_at
  json.team item.team.name
  json.language item.service.language
end
