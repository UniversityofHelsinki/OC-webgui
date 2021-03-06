# Retrieves data for the current status of each agent who is logged in, and uses AgentStatusUpdater class to update them in the DB.
class TrackAgentStatusesJob
  extend Now

  def self.perform
    current = BackendService.new.get_agent_online_state.map do |data|
      AgentStatus.new(agent: Agent.find_or_create(data[:agent_id], data[:name], data[:team]),
                      status: data[:status],
                      time_in_status: data[:time_in_status])
    end
    lunch current
    last_success = Rails.cache.read('track_agent_statuses_job_last_success')
    AgentStatusUpdater.new(now, last_success).update_statuses(current)
    Rails.cache.write('track_agent_statuses_job_last_success', now)
  end

  # Checks if agents are currently on lunch, and stores the information in cache, where it can be retrieved by controllers.
  # This information can be displayed in the frontend to allow easy checking of which agents have already been to lunch.
  def self.lunch(states)
    luncheds = Rails.cache.read 'lunched'

    if luncheds.nil?
      eaters = AgentStatusContactsService.new.statuses('Helpdesk', now.beginning_of_day, now.end_of_day, 'Ruokatunti')
      luncheds = Set.new eaters.pluck(:agent_id)
    end

    states.each do |data|
      agent_id = data[:agent_id].to_i
      luncheds.add agent_id if data[:status] == 'Ruokatunti'
    end

    Rails.cache.write 'lunched', luncheds
  end

  def self.queue_priority
    1
  end

  def self.queue_respond_timeout
    5
  end
end
