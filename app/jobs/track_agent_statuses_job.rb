# Retrieves agent statuses and calls AgentStatusUpdater to update them where necessary
class TrackAgentStatusesJob
  include Now

  def perform
    current = BackendService.new.get_agent_online_state.map do |data|
      AgentStatus.new(agent_id: data[:agent_id],
                      team: data[:team],
                      name: data[:name],
                      status: data[:status],
                      time_in_status: data[:time_in_status])
    end
    log = JobLog.new('TrackAgentStatusesJob')
    if AgentStatusUpdater.new(now, log.last_success).update_statuses(current)
      log.log_success
    else
      log.log_failure
    end
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
end
