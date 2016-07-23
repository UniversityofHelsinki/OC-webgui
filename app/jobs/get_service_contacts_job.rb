# Gets contacts for every agent in a specific service and stores the results in DB
class GetServiceContactsJob
  def initialize(service_id, start_date, end_date)
    @service_id = service_id
    @start_date = start_date
    @end_date = end_date
  end

  def perform
    sleep 0.2
    agents = Agent.all
    contacts = []
    BackendService.new.get_service_contacts(@service_id, @start_date, @end_date).each do |data|
      if data[:agent_name] && data[:agent_name] != ''
        data[:agent_id] = find_agent_id(agents, data[:agent_name])
        next if data[:agent_id].nil?
      else
        data[:agent_id] = nil
      end
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
    4
  end

  private

  def add_contact(contacts, data)
    contacts.push(agent_id: data[:agent_id],
                  service_id: @service_id,
                  contact_type: data[:contact_type],
                  ticket_id: data[:ticket_id],
                  arrived_in_queue: data[:arrived],
                  forwarded_to_agent: data[:forwarded_to_agent],
                  answered: data[:answered],
                  call_ended: data[:call_ended],
                  handling_ended: data[:after_call_ended],
                  direction: data[:direction])
  end

  def find_agent_id(agents, agent_name)
    agent_name = agent_name.split
    agent = agents.find { |agt| agt.first_name == agent_name[1] && agt.last_name == agent_name[0] }
    return agent.id if agent
    nil
  end
end
