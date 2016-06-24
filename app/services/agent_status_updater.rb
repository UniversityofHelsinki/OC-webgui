class AgentStatusUpdater

	def update_statuses(previous_statuses, new_statuses)
		if (!previous_statuses) 
			previous_statuses = []
		end
		if (!new_statuses)
			new_statuses = []
		end

		#Map statuses into a hash where the key is the agent ID and the result is the AgentStatus object for that agent
		previous_statuses = Hash[previous_statuses.map { |agent| [agent.agent_id, agent]}]
		new_statuses = Hash[new_statuses.map { |agent| [agent.agent_id, agent]}]

		check_signed_out_agents(previous_statuses, new_statuses)

		update_statuses_from_new_results(previous_statuses, new_statuses)
		
	end

	private

	def close_last_open_status(agent)
		open_statuses = AgentStatus.where(agent_id: agent.agent_id, open: true)
		open_statuses.each { |status| status.open = false; status.save } #There should only ever be one open status at a time for each agent, looping through just in case
	end

	def save_new_status(agent)
		AgentStatus.create(agent_id: agent.agent_id, status: agent.status, team: agent.team, open: true)
	end

	def check_signed_out_agents(previous_statuses, new_statuses)
		previous_statuses.each do |previous_status| 
			previous_status = previous_status[1] #This is needed due to how looping through Hashes works in Ruby
			if !(new_statuses[previous_status.agent_id])
				close_last_open_status(previous_status)
			end
		end
	end

	def update_statuses_from_new_results(previous_statuses, new_statuses)
		new_statuses.each do |agent| 
			agent = agent[1]

			#Check if any agents are found who did not appear in the last results, and if so create a new open status for them
			if (!previous_statuses[agent.agent_id])
				save_new_status(agent)
			#Previous status found for the same agent
			else
				previous = previous_statuses[agent.agent_id]
				
				#Check if previous agent is a different agent than the new one
				if (previous.status != agent.status || agent.time_in_status.to_i < previous.time_in_status.to_i)
					close_last_open_status(previous)
					save_new_status(agent)
				end

			end
		end
	end

end
