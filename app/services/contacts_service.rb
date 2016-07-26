# Calculates various statistics data based on Contact objects
class ContactsService
  def num_answered_calls(team_name, start_time, end_time)
    answered_contacts(team_name, start_time, end_time).count
  end

  def answered_contacts(team_name, start_time, end_time)
    find_contacts(team_name, start_time, end_time, { contact_type: 'PBX' }, { call_ended: nil, answered: nil, service_id: 120 })
  end

  def average_call_duration(team_name, start_time, end_time)
    average_duration(answered_contacts(team_name, start_time, end_time), 'answered', 'call_ended')
  end

  def average_after_call_duration(team_name, start_time, end_time)
    contacts = find_contacts(team_name, start_time, end_time, { contact_type: 'PBX' },
                                                              { call_ended: nil, answered: nil, service_id: 120, handling_ended: nil })
    average_duration(contacts, 'call_ended', 'handling_ended')
  end

  def missed_contacts(team_name, start_time, end_time)
    find_contacts(team_name, start_time, end_time, { contact_type: 'PBX', answered: nil, handling_ended: nil, direction: "I" },
                                                   { call_ended: nil, service_id: 120 })
  end

  def answered_percentage(team_name, start_time, end_time)
    answered = num_answered_calls(team_name, start_time, end_time)
    missed = num_missed_calls(team_name, start_time, end_time)
    return 100.0 if missed == 0
    (answered.to_f / (answered + missed)).round(3) * 100
  end

  def num_missed_calls(team_name, start_time, end_time)
    missed_contacts(team_name, start_time, end_time).count
  end

  def average_missed_call_duration(team_name, start_time, end_time)
    average_duration(missed_contacts(team_name, start_time, end_time), 'arrived_in_queue', 'call_ended')
  end

  def calls_by_hour(team_name, start_time, end_time)
    gmt_offset = Time.now.getlocal.gmt_offset
    select = "EXTRACT(HOUR FROM contacts.created_at + '#{gmt_offset} seconds') AS hour, COUNT(*) AS count"
    data = answered_contacts(team_name, start_time, end_time).select(select).group('hour')

    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['count'] }
    result
  end

  private

  def find_contacts(team_name, start_time, end_time, has_conditions, not_conditions)
    Contact.joins(service: :team).where(teams: { name: team_name }, arrived_in_queue: start_time..end_time).where(has_conditions).where.not(not_conditions)
  end

  def average_duration(contacts, period_start_field, period_end_field)
    contacts.select("ROUND(AVG(EXTRACT(EPOCH FROM contacts.#{period_end_field}- contacts.#{period_start_field}))) AS avg")[0]['avg'] || 0
  end
end
