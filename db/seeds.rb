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

# Hardcoded because information not reliably available via SOAP
service_group_ids_by_team = { 'Hakijapalvelut' => 7,
                              'Helpdesk' => 4,
                              'Opiskelijaneuvonta' => 6,
                              'Puhelinvaihde' => 3,
                              'OrangeContact 1' => 2,
                              'Uaf' => 9 }

backend_service.get_teams.each do |team_name|
  Team.find_or_initialize_by(name: team_name).tap do |team|
    team.filter = team_name == 'Helpdesk'
    team.service_group_id = service_group_ids_by_team[team_name]
    team.save
  end
end

backend_service.get_agents.each do |data|
  Agent.find_or_initialize_by(id: data[:agent_id]).tap do |agent|
    agent.id = data[:agent_id]
    agent.first_name = data[:first_name]
    agent.last_name = data[:last_name]
    agent.team = Team.find_or_create_by(name: data[:team_name])
    agent.save
  end
end

# Hardcoded because this information is not available via SOAP
teams_by_service = { 122 => 'Puhelinvaihde',
                     151 => 'Puhelinvaihde',
                     124 => 'Opiskelijaneuvonta',
                     161 => 'Hakijapalvelut',
                     180 => 'Hakijapalvelut',
                     181 => 'Hakijapalvelut',
                     182 => 'Hakijapalvelut',
                     120 => 'Helpdesk',
                     121 => 'Helpdesk',
                     131 => 'Helpdesk',
                     133 => 'Helpdesk',
                     135 => 'Helpdesk',
                     137 => 'Helpdesk',
                     192 => 'Uaf' }

backend_service.get_services.each do |data|
  Service.find_or_initialize_by(id: data[:id]).tap do |service|
    service.id = data[:id]
    service.name = data[:name]
    service.team = Team.find_by(name: teams_by_service[data[:id]])

    if service.name.include? "Eng"
      service.language = "English"
    elsif service.name.include? "Fin"
      service.language = "Finnish"
    elsif service.name.include?("Sve") || service.name.include?("Swe")
      service.language = "Swedish"
    else
      service.language = "Unknown"
    end
    service.save
  end
end
