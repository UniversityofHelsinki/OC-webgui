# Compares two arrays of AgentStatus objects. The assumption is that they represent two queries made to the OC SOAP service, where
# new_statuses contains results from the most recent query, and previous_from the one made prior to it. These queries are compared,
# and AgentStatuses are created and updated when new ones or changes are detected.
# Current_time parameter should always be current time (Time.zone.now), except for tests
# Last_success should contain timestamp of the last time the update job was run successfully
class AgentStatusUpdater
  include Now
  def initialize(current_time, last_success)
    @current_time = current_time
    @last_success = last_success
  end

  def update_statuses(new_statuses)
    new_statuses ||= []

    # Map statuses into a hash where the key is the agent ID and the result is the AgentStatus object for that agent
    @previous_statuses = Hash[AgentStatus.where(open: true).map { |status| [status.agent_id, status] }]
    @new_statuses = Hash[new_statuses.map { |status| [status.agent_id, status] }]
    @statuses_to_create = []

    check_when_new_statuses_opened
    check_signed_out_agents
    # If AgentStatus data is unreliable, discard all changes and wait for the next, hopefully reliable, data
    return false unless update_new_and_changed_statuses
    save_updates
    true
  end

  private

  def check_when_new_statuses_opened
    @new_statuses.each { |_agent_id, status| status.created_at = Time.zone.at(@current_time.to_i - status.time_in_status.to_i) }
  end

  def check_signed_out_agents
    @previous_statuses.each do |agent_id, status|
      status.open = false unless @new_statuses[agent_id]
    end
  end

  def update_new_and_changed_statuses
    @new_statuses.each do |agent_id, status|
      # If agent didn't appear in the previous query, it means they must have signed in, so create a new status for them
      if !@previous_statuses[agent_id]
        save_new_status(status)
      else
        return false unless status_data_is_reliable(agent_id, status)
      end
    end
    true
  end

  def status_data_is_reliable(agent_id, status)
    previous = @previous_statuses[agent_id]
    # The agent's status has changed if either the status name is different, or the time spent in it is less than before
    if previous.status != status.status ||
       status.created_at > previous.created_at + 6.seconds
      # Ensure that status data is reliable before saving any changes
      return false unless plausibly_new_status? status

      previous.open = false
      save_new_status(status)
    end
    true
  end

  def save_updates
    items_to_close = @previous_statuses.map { |_agent_id, status| status.id unless status.open }
    AgentStatus.where(id: items_to_close)
               .update_all(open: false, closed: @current_time, last_reliable_status: @last_success)
    AgentStatus.create(@statuses_to_create)
  end

  def save_new_status(status)
    @statuses_to_create.push(agent_id: status.agent_id,
                             status: status.status,
                             open: true,
                             created_at: status.created_at)
  end

  # It is possible for an agent status to appear new even if it's actually an old one. This can happen in case SOAP response is delayed
  # due to lag. This check will return false if the given status seems to be an old one, not a new one.
  def plausibly_new_status?(status)
    return true unless @last_success
    status.created_at >= @last_success
  end
end
