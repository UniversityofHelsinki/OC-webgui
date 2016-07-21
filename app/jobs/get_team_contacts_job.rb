# Gets all contacts for every agent in a team for the specified timeframe
class GetTeamContactsJob
  def initialize(team, start_date, end_date)
    @team = team
    @start_date = start_date
    @end_date = end_date
  end

  def perform
    agents = Agent.all
    services = Service.all
    contacts = []
    BackendService.new.get_team_contacts(@team, @start_date, @end_date).each do |data|
      data[:agent] = find_agent(agents, data[:agent_name])
      next unless data[:agent]
      data[:service] = find_service(services, data[:service_name])
      add_contact(contacts, data)
    end
    Contact.create(contacts)
  end

  def queue_name
    'contacts'
  end

  def max_run_time
    600.seconds
  end

  def max_attempts
    5
  end

  private

  def add_contact(contacts, data)
    contacts.push(agent_id: data[:agent].id,
                  service_id: data[:service].id,
                  contact_type: data[:contact_type],
                  ticket_id: data[:ticket_id],
                  arrived_in_queue: data[:arrived],
                  forwarded_to_agent: data[:forwarded_to_agent],
                  answered: data[:answered],
                  call_ended: data[:call_ended],
                  handling_ended: data[:after_call_ended],
                  direction: data[:direction])
  end

  def find_agent(agents, agent_name)
    agent_name = agent_name.split
    agents.find { |agt| agt.first_name == agent_name[1] && agt.last_name == agent_name[0] }
  end

  def find_service(services, service_name)
    services.find { |svc| svc.name == service_name } || Service.new
  end
end
