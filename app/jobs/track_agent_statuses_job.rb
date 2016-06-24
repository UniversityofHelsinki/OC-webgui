class TrackAgentStatusesJob
	def perform
		current = BackendService.new.get_agent_online_state.map do |data|
			AgentStatus.new(agent_id: data[:agent_id],
				team: data[:team],
				status: data[:status],
				time_in_status: data[:time_in_status])
		end

		previous = Rails.cache.read("get_agent_online_state")
		AgentStatusUpdater.new.update_statuses(previous, current)
		Rails.cache.write("get_agent_online_state", current)		
	end
end