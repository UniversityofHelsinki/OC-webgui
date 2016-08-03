json.array!(@agents) do |agent|
  json.extract! agent, :first_name, :last_name, :id
end
