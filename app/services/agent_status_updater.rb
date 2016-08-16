# Provides functionality for tracking the statuses of Agents over time and storing the current status of logged in Agents in the DB.
# This is done by comparing the latest agent status data from OC to AgentStatus data stored in the DB. Any changes are updated.
#
# Current_time parameter should always be current time (Time.zone.now), except for tests
# Last_success should contain timestamp of the last time the update job was run successfully
class AgentStatusUpdater
  include Now
  def initialize(current_time, last_success)
    @current_time = current_time
    @last_success = last_success
  end

  # Updates the statuses of each logged in agent. Any statuses that are no longer active will be marked as closed,
  # and their closed time updated to current time. Any new statuses (belonging either to agents who logged in, or whose
  # status has changed) will be stored as new AgentStatus objects in the DB such that their open status is set to true.
  #
  # new_statuses should be an Array of AgentStatus objects representing the current state of each logged in agent
  def update_statuses(new_statuses)
    new_statuses ||= []

    # Map statuses into a hash where the key is the agent ID and the result is the AgentStatus object for that agent
    @previous_statuses = Hash[AgentStatus.where(open: true).map { |status| [status.agent_id, status] }]
    @new_statuses = Hash[new_statuses.map { |status| [status.agent_id, status] }]
    @statuses_to_create = []

    check_when_new_statuses_opened
    check_signed_out_agents
    update_new_and_changed_statuses
    save_updates
  end

  private

  # Assign created_at time for each new status to help determine whether the statuses are the same as those already stored in DB
  def check_when_new_statuses_opened
    @new_statuses.each { |_agent_id, status| status.created_at = Time.zone.at(@current_time.to_i - status.time_in_status.to_i) }
  end

  def check_signed_out_agents
    @previous_statuses.each do |agent_id, status|
      status.open = false unless @new_statuses[agent_id]
    end
  end

  # Create a new AgentStatus for each agent who either logged in since the last check, or whose status has changed
  def update_new_and_changed_statuses
    @new_statuses.each do |agent_id, status|
      # If agent didn't appear in the previous query, it means they must have signed in, so create a new status for them
      if !@previous_statuses[agent_id]
        save_new_status(status)
      else
        check_if_status_has_changed(agent_id, status)
      end
    end
  end

  def check_if_status_has_changed(agent_id, status)
    previous = @previous_statuses[agent_id]
    # The agent's status has changed if either the status name is different, or the time spent in it is less than before
    # Since AgentStatus data from OC is only updated every 5 seconds and there may be random delays, there is a 10 second buffer
    # to ensure that an existing status is not registered as a changed one.
    if previous.status != status.status ||
       status.created_at > previous.created_at + 10.seconds

      previous.open = false
      save_new_status(status)
    end
  end

  def save_updates
    items_to_close = @previous_statuses.map { |_agent_id, status| status.id unless status.open }
    AgentStatus.where(id: items_to_close)
               .update_all(open: false, closed: @current_time, last_reliable_status: @last_success) unless items_to_close.empty?
    AgentStatus.create(@statuses_to_create)
  end

  # Adds status to list of statuses to be saved later
  def save_new_status(status)
    @statuses_to_create.push(agent_id: status.agent_id,
                             status: status.status,
                             open: true,
                             created_at: @current_time)
  end
end
