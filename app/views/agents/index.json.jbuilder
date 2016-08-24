json.array!(@agents) do |agent|
  json.extract! agent, :first_name, :last_name, :id

  json.team do
    json.id agent.team.id
    json.name agent.team.name
  end
end
