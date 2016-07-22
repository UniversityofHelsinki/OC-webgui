# Retrieves agent statuses and calls AgentStatusUpdater to update them where necessary
class TrackAgentStatusesJob
  include Now

  def perform
    current = BackendService.new.get_agent_online_state.map do |data|
      AgentStatus.new(agent: Agent.find_or_create(data[:agent_id], data[:name], data[:team]),
                      status: data[:status],
                      time_in_status: data[:time_in_status])
    end
    lunch current
    log = JobLog.new('TrackAgentStatusesJob')
    AgentStatusUpdater.new(now, log.last_success).update_statuses(current)
  end

  def lunch(states)
    luncheds = Rails.cache.read 'lunched'

    @contacts_service = ContactsService.new
    time = Time.zone.now
    start_time = time.beginning_of_day
    end_time = time.end_of_day
    team_name = 'Helpdesk'

    if luncheds.nil?
      eaters = @contacts_service.statuses(team_name, start_time, end_time, 'Ruokatunti')
      luncheds = Set.new eaters.pluck(:agent_id)
    end

    luncheds.add states.select { |s| s['status'] == 'Tauko' }.map { |a| a[:agent_id] }

    Rails.cache.write 'lunched', luncheds
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
