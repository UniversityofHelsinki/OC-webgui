# Retrieves agent statuses and calls AgentStatusUpdater to update them where necessary
class TrackAgentStatusesJob
  include Now

  def perform
    current = BackendService.new.get_agent_online_state.map do |data|
      agent_has_eaten(data) if data[:status] == 'Ruokatunti'
      AgentStatus.new(agent: Agent.find_or_create(data[:agent_id], data[:name], data[:team]),
                      status: data[:status],
                      time_in_status: data[:time_in_status])
    end
    log = JobLog.new('TrackAgentStatusesJob')
    AgentStatusUpdater.new(now, log.last_success).update_statuses(current)
  end

  def agent_has_eaten(data)
    agent_id = data[:agent_id].to_i
    luncheds = Rails.cache.fetch('lunched', force: true)
    return if luncheds.nil?
    luncheds.push(agent_id) unless luncheds.contains? agent_id
    Rails.cache.fetch('lunched', force: true) { luncheds }
  end

  def max_run_time
    5.seconds
  end

  def max_attempts
    1
  end

  def success(*)
    JobLog.new('TrackAgentStatusesJob').log_success
  end

  def failure(*)
    JobLog.new('TrackAgentStatusesJob').log_failure
  end

  def queue_name
    'statuses'
  end
end
