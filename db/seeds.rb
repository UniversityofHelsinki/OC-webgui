# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

State.create(name: 'Puhelu', filter: true)
State.create(name: 'Backoffice', filter: true)
State.create(name: 'Tauko', filter: true)
State.create(name: 'Chat', filter: true)
State.create(name: 'Palaveri', filter: true)
State.create(name: 'Teljentä', filter: true)
State.create(name: 'Vapaa', filter: true)
State.create(name: 'Jälkikirjaus', filter: true)
State.create(name: 'Vikapäivystys', filter: true)
State.create(name: 'Ruokatunti', filter: true)

backend_service = BackendService.new

backend_service.get_teams.each do |team|
  Team.create(name: team,
              filter: team == 'Helpdesk')
end

backend_service.get_agents.each do |data|
  Agent.find_or_initialize_by(id: data[:agent_id]).tap do |agent|
    agent.id = data[:agent_id]
    agent.first_name = data[:first_name]
    agent.last_name = data[:last_name]
    agent.team = Team.find_by!(name: data[:team_name])
    agent.save
  end
end
