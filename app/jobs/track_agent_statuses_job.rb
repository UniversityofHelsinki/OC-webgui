# Retrieves agent statuses and calls AgentStatusUpdater to update them where necessary
class TrackAgentStatusesJob
  include Now

  def perform
    current = BackendService.new.get_agent_online_state.map do |data|
      if data[:status] === 'Ruokatunti'
        luncheds = Rails.cache.fetch('lunched', force: true)
        agentname = data[:name].to_s
        if luncheds.nil?
          luncheds = []
        end
        luncheds.push(agentname)
        luncheds = luncheds.uniq
        Rails.cache.fetch('lunched', force: true) { luncheds }
      end
      AgentStatus.new(agent: Agent.find_or_create(data[:agent_id], data[:name], data[:team]),
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

  def queue_name
    'statuses'
  end
end
