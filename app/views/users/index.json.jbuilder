json.array!(@users) do |user|
  json.extract! user, :id, :username, :is_admin
end
