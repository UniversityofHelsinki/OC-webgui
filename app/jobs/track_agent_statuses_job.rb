# Retrieves agent statuses and calls AgentStatusUpdater to update them where necessary
class TrackAgentStatusesJob
  include Now

  def perform
    current = BackendService.new.get_agent_online_state.map do |data|
      AgentStatus.new(agent: Agent.find_or_create(data[:agent_id], data[:name], data[:team]),
                      status: data[:status],
                      time_in_status: data[:time_in_status])
    end
    log = JobLog.new('TrackAgentStatusesJob')
    log.log_success if AgentStatusUpdater.new(now, log.last_success).update_statuses(current)
  end

  def max_run_time
    5.seconds
  end

  def max_attempts
    1
  end

  def failure(*)
    JobLog.new('TrackAgentStatusesJob').log_failure
  end

  def queue_name
    'statuses'
  end
end
