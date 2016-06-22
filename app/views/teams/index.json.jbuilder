json.array!(@teams) do |team|
  json.extract! team, :name, :filter
end
