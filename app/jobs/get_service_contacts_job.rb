# Gets contacts for every agent in a specific service and stores the results in DB
class GetServiceContactsJob
  def self.perform(service_id, start_date, end_date)
    sleep 0.2
    agents = Agent.all
    contacts = []
    BackendService.new.get_service_contacts(service_id, start_date, end_date).each do |data|
      if data[:agent_name] && data[:agent_name] != ''
        data[:agent_id] = find_agent_id(agents, data[:agent_name])
        next if data[:agent_id].nil?
      else
        data[:agent_id] = nil
      end
      data[:service_id] = service_id
      add_contact(contacts, data)
    end
    Contact.create(contacts)
  end

  def self.queue_priority
    10
  end

  def self.queue_respond_timeout
    120
  end

  def self.add_contact(contacts, data)
    contacts.push(agent_id: data[:agent_id],
                  service_id: data[:service_id],
                  contact_type: data[:contact_type],
                  ticket_id: data[:ticket_id],
                  arrived_in_queue: data[:arrived],
                  forwarded_to_agent: data[:forwarded_to_agent],
                  answered: data[:answered],
                  call_ended: data[:call_ended],
                  handling_ended: data[:after_call_ended],
                  direction: data[:direction])
  end

  def self.find_agent_id(agents, agent_name)
    agent_name = agent_name.split
    agent = agents.find { |agt| agt.first_name == agent_name[1] && agt.last_name == agent_name[0] }
    return agent.id if agent
    nil
  end
end
