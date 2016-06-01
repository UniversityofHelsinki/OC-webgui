json.array!(@agents) do |agent|
  json.extract! agent, :id, :agent_id, :name, :team, :status, :time_in_status
end
