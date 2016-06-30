class GetAgentStatusesJob

  def get_contacts
    tracks = [137] # Add rest of the language tracks!
    today = Time.zone.today
    yesterday = today - 1.day	# DAYLIGHT SAVING NOT FACTORED IN!!!
    agents = BackendService.new.get_agents
    
    agents.each {|agent|
      tracks.each { |track|
        contacts = BackendService.new.get_agent_contacts(agent.agent_id, start_date, end_date, track)
      }

    }


=begin
    current = BackendService.new.get_agent_contacts(agent_id, start_date, end_date, serviceID).map do |data|
		AgentStatus.new(
			agent_id: data[:agent_id],
			team: data[:team],
			name: data[:name],
			status: data[:status],
			time_in_status: data[:time_in_status]
				)
		end
=end
        
    end

end
