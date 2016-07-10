json.array!(@agent_statuses) do |agent_status|
  json.extract! agent_status, :agent_id, :status, :created_at
  json.name agent_status.agent.last_name + ' ' + agent_status.agent.first_name
  json.team agent_status.agent.team.name
end
