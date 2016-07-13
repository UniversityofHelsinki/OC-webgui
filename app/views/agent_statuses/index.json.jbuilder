json.array!(@agent_statuses) do |agent_status|
  json.id agent_status.agent.id
  json.first_name agent_status.agent.first_name
  json.last_name agent_status.agent.last_name
  json.extract! agent_status, :status, :created_at

  json.team do
    json.id agent_status.agent.team.id
    json.name agent_status.agent.team.name
  end
end
