json.array!(@agent_statuses) do |agent_status|
  json.extract! agent_status, :agent_id, :name, :team, :status, :created_at
end
