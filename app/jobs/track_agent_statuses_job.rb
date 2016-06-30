# Retrieves agent statuses and calls AgentStatusUpdater to update them where necessary
class TrackAgentStatusesJob
  def perform
    current = BackendService.new.get_agent_online_state.map do |data|
      AgentStatus.new(agent_id: data[:agent_id],
                      team: data[:team],
                      name: data[:name],
                      status: data[:status],
                      time_in_status: data[:time_in_status])
    end

    previous = AgentStatus.where(open: true)
    AgentStatusUpdater.new.update_statuses(previous, current)
  end
end
