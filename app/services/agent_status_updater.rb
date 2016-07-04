# Compares two arrays of AgentStatus objects. The assumption is that they represent two queries made to the OC SOAP service, where
# new_statuses contains results from the most recent query, and previous_from the one made prior to it. These queries are compared,
# and AgentStatuses are created and updated when new ones or changes are detected.
class AgentStatusUpdater
  def update_statuses(previous_statuses, new_statuses)
    previous_statuses = [] unless previous_statuses
    new_statuses = [] unless new_statuses

    # Map statuses into a hash where the key is the agent ID and the result is the AgentStatus object for that agent
    @previous_statuses = Hash[previous_statuses.map { |agent| [agent.agent_id, agent] }]
    @new_statuses = Hash[new_statuses.map { |agent| [agent.agent_id, agent] }]

    check_signed_out_agents
    update_statuses_from_new_results
  end

  private

  def close_last_open_status(agent)
    AgentStatus.where(agent_id: agent.agent_id, open: true)
               .update_all(open: false, closed: Time.zone.now)
  end

  def save_new_status(agent)
    time = if @previous_statuses == []
             Time.zone.now - agent.time_in_status
           else
             Time.zone.now
           end
    AgentStatus.create(agent_id: agent.agent_id, name: agent.name, status: agent.status, team: agent.team, open: true, created_at: time)
  end

  def check_signed_out_agents
    @previous_statuses.each do |agent_id, agent|
      close_last_open_status(agent) unless @new_statuses[agent_id]
    end
  end

  def check_if_status_has_changed(agent_id, agent)
    previous = @previous_statuses[agent_id]

    # The agent's status has changed if either the status name is different, or the time spent in it is less than before
    if previous.status != agent.status ||
       agent.time_in_status.to_i < previous.time_in_status.to_i

      close_last_open_status(previous)
      save_new_status(agent)
    end
  end

  def update_statuses_from_new_results
    @new_statuses.each do |agent_id, agent|
      # If agent didn't appear in the previous query, it means they must have signed in, so create a new status for them
      if !@previous_statuses[agent_id]
        save_new_status(agent)
      else
        check_if_status_has_changed(agent_id, agent)
      end
    end
  end
end
