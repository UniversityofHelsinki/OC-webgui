# Gets contacts for every agent in a specific service and stores the results in DB
class GetServiceContactsJob
  def self.perform(service_id, start_date, end_date)
    sleep 0.2
    agents = Agent.all
    BackendService.new.get_service_contacts(service_id, start_date, end_date).each do |data|
      result = find_agent_id(agents, data[:agent_name])
      next if result[:store] == false
      contact = Contact.find_or_initialize_by(ticket_id: data[:ticket_id])
      contact.agent_id = result[:agent_id]
      contact.service_id = service_id
      contact.update_attributes(contact_params(data))
    end
  end

  def self.queue_priority
    10
  end

  def self.queue_respond_timeout
    120
  end

  def self.contact_params(data)
    data.slice(:contact_type, :ticket_id, :arrived, :forwarded_to_agent, :answered, :call_ended, :after_call_ended, :direction)
  end

  # Returns a hash which contains result for whether the contact should be stored, and an agent ID where possible
  # First parameter should contain an array of all agents whose contacts we wish to track(typically all active agents)
  # Second parameter should contain the name of the agent in the current contact as "Lastname Firstname"
  def self.find_agent_id(agents, agent_name)
    # If agent name is nil or emtpy, it means the contact is a missed or queued contact, and should be added
    return { store: true, agent_id: nil } if agent_name.nil? || agent_name.empty?
    # If an agent name exists, but it doesn't match the name of any agents whose contacts we wish to track, discard the contact
    # Generally this applies to any agents who are not stored in OC SOAP DB, which can happen in case of very old contacts
    last_name, first_name = agent_name.split
    agent = agents.find { |agt| agt.first_name = first_name && agt.last_name == last_name }
    return { store: false, agent_id: nil } if agent.nil?
    { store: true, agent_id: agent.id }
  end
end
