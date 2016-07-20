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
      agent_name = data[:agent_name].split
      agent = agents.find { |agt| agt.first_name == agent_name[1] && agt.last_name == agent_name[0] }
      next unless agent
      service = services.find { |svc| svc.name == data[:service_name] } || Service.new
      contacts.push(agent_id: agent.id,
                    service_id: service.id,
                    contact_type: data[:contact_type],
                    ticket_id: data[:ticket_id],
                    arrived_in_queue: data[:arrived],
                    forwarded_to_agent: data[:call_forwarded_to_agent],
                    answered: data[:answered],
                    call_ended: data[:call_ended],
                    handling_ended: data[:after_call_ended],
                    direction: data[:direction])
    end
    Contact.create(contacts)
  end

  def queue_name
    'contacts'
  end

  def max_run_time
    3600.seconds
  end

  def max_attempts
    5
  end
end
