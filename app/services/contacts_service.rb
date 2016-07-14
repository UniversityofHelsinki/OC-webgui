# Provides service for calculating Contact objects out of AgentStatus data that corresponds to answered contacts
class ContactsService
  def initialize
  end

  def contacts_for_team(team_name, starttime, endtime)
    convert_to_contacts(contact_statuses(team_name, starttime, endtime))
  end

  def answered_calls(team_name, start_time, end_time)
    contact_statuses(team_name, start_time, end_time).count
  end

  def average_call_duration(team_name, start_time, end_time)
    average_duration(contact_statuses(team_name, start_time, end_time))
  end

  def average_after_call_duration(team_name, start_time, end_time)
    average_duration(statuses(team_name, start_time, end_time, 'Jälkikirjaus'))
  end

  def calls_by_hour(team_name, start_time, end_time)
    gmt_offset = Time.now.getlocal.gmt_offset
    select = "EXTRACT(HOUR FROM agent_statuses.created_at + '#{gmt_offset} seconds') AS hour, COUNT(*) AS count"
    data = contact_statuses(team_name, start_time, end_time).select(select).group('hour')

    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['count'] }
    result
  end

  def lunched
    lunched = Rails.cache.fetch('lunched', force: true)
    return [] if lunched.nil?
    lunched
  end

  private

  def convert_to_contacts(statuses)
    statuses.map do |status|
      contact = Contact.new(agent_id: status.agent_id, answered: status.created_at, call_ended: status.closed)
      after_call = after_call_for(contact)
      contact.handling_ended = after_call.closed if after_call
      contact
    end
  end

  # Returns the after call state for the specified contact if one is found with reasonable confidence
  def after_call_for(contact)
    after_call = AgentStatus.find_by('created_at > ? AND agent_id = ?', contact.call_ended, contact.agent_id)
    return nil unless after_call
    if after_call.status == 'Jälkikirjaus' && after_call.created_at.to_i <= (contact.call_ended.to_i + 2) && !after_call.open
      return after_call
    end
    nil
  end

  def statuses(team_name, start_time, end_time, statuses)
    AgentStatus.joins(agent: :team).where(open: false, teams: { name: team_name }, status: statuses, created_at: start_time..end_time)
  end

  def contact_statuses(team_name, start_time, end_time)
    statuses(team_name, start_time, end_time, ['Puhelu', 'Puhelu (Ulos)', 'Puhelu (Sisään)', 'Ulossoitto', 'Chat'])
  end

  def average_duration(statuses)
    statuses.select('ROUND(AVG(EXTRACT(EPOCH FROM agent_statuses.closed - agent_statuses.created_at))) AS avg')[0]['avg'] || 0
  end
end
