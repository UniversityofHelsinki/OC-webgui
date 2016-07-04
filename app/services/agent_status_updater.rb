# Compares two arrays of AgentStatus objects. The assumption is that they represent two queries made to the OC SOAP service, where
# new_statuses contains results from the most recent query, and previous_from the one made prior to it. These queries are compared,
# and AgentStatuses are created and updated when new ones or changes are detected.
class AgentStatusUpdater
  def initialize(current_time, last_success)
    @current_time = current_time
    @last_success = last_success
  end

  def update_statuses(previous_statuses, new_statuses)
    # previous_statuses = [] unless previous_statuses
    new_statuses = [] unless new_statuses

    # Map statuses into a hash where the key is the agent ID and the result is the AgentStatus object for that agent
    @previous_statuses = Hash[AgentStatus.where(open: true).map { |status| [status.agent_id, status] }]
    @new_statuses = Hash[new_statuses.map { |status| [status.agent_id, status] }]

    check_when_new_statuses_opened

    check_signed_out_agents
    update_statuses_from_new_results
  end

  private

  def check_when_new_statuses_opened
    @new_statuses.each { |agent_id, status| status.created_at = @current_time - status.time_in_status.to_i }
  end

  def close_last_open_status(status)
    AgentStatus.where(agent_id: status.agent_id, open: true)
               .update_all(open: false, closed: Time.zone.now)
  end

  def save_new_status(status)
    time = @current_time - status.time_in_status.to_i
    AgentStatus.create(agent_id: status.agent_id, name: status.name, status: status.status, team: status.team, open: true, created_at: time)
  end

  def check_signed_out_agents
    @previous_statuses.each do |agent_id, status|
      close_last_open_status(status) unless @new_statuses[agent_id]
    end
  end

  def check_if_status_has_changed(agent_id, status)
    previous = @previous_statuses[agent_id]
    # The agent's status has changed if either the status name is different, or the time spent in it is less than before
    if previous.status != status.status ||
       status.created_at > previous.created_at

      close_last_open_status(previous)
      save_new_status(status)
    end
  end

  def update_statuses_from_new_results
    @new_statuses.each do |agent_id, status|
      # If agent didn't appear in the previous query, it means they must have signed in, so create a new status for them
      if !@previous_statuses[agent_id]
        save_new_status(status)
      else
        check_if_status_has_changed(agent_id, status)
      end
    end
  end
end
