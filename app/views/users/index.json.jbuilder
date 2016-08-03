json.array!(@users) do |user|
  json.extract! user, :id, :username, :is_admin, :agent_id
end
