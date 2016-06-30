class GetAgentStatusesJob

  # Getting agents and their contacts from Orange Contact system
  def get_agents_and_contacts
    @tracks = [137] # Add rest of the language tracks!
    @contacts = [];
    today = Time.zone.today
    yesterday = today - 1.day	# DAYLIGHT SAVING NOT FACTORED IN!!!
    agents = BackendService.new.get_agents
    agent_id = 0;
    
    agents.each do |agent|
      agent_id = agent.agent_id
      tracks.each do |track|
        agent_contacts = BackendService.new.get_agent_contacts(agent_id, today, yesterday, track)
        @contacts.push(agent_contacts)
      end
    end
      
    return @contacts  
  end


  # Method for transfering contacts got from Orange Contact system to database
  def write_contacts_to_database



  end

end
