json.array!(@states) do |state|
  json.extract! state, :name, :filter
end
