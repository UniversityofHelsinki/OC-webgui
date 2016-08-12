# Calculates various statistics data based on Contact objects.
class ContactsService
  # Filter_by_model should either be an Agent or Team object
  # If it is an Agent, service will provide data for contacts for the specified agent within the specified timeframe
  # If it is a Team, data will be provided for the specified team within the specified timeframe
  def initialize(filter_by_model, start_time, end_time)
    if filter_by_model.is_a? Team
      @contacts = Contact.joins(:service).where(services: { team_id: filter_by_model.id }, arrived: start_time..end_time)
    elsif filter_by_model.is_a? Agent
      @contacts = Contact.where(agent: filter_by_model, arrived: start_time..end_time)
    else
      @contacts = Contact.where(arrived: start_time..end_time)
    end
  end

  # Total number of answered calls within the timeframe
  def num_answered_calls
    answered_contacts.count
  end

  # Average call duration in seconds
  def average_call_duration
    average_duration(finished_contacts, 'answered', 'call_ended')
  end

  # Average after call duration in seconds
  def average_after_call_duration
    average_duration(closed_contacts, 'call_ended', 'after_call_ended')
  end

  # % of calls answered
  def answered_percentage
    answered = num_answered_calls
    missed = num_missed_calls
    return 100.0 if (answered + missed) == 0
    (answered.to_f / (answered + missed) * 100).round(1)
  end

  # Total number of missed calls within the timeframe
  def num_missed_calls
    missed_contacts.count
  end

  # Average duration missed calls waited in the queue
  def average_missed_call_duration
    average_duration(missed_contacts, 'arrived', 'call_ended')
  end

  # Average duration answered calls waited in the queue, including calls which did not have to wait in queue at all
  def average_queue_duration
    average_duration(answered_contacts, 'arrived', 'forwarded_to_agent')
  end

  # Returns an array of length 24 where each index corresponds to the hour of the day, and value of each index to the average
  # queue duration, in seconds, during that hour
  def average_queue_duration_by_hour
    gmt_offset = Time.now.getlocal.gmt_offset
    select = [
      "EXTRACT(HOUR FROM contacts.arrived + '#{gmt_offset} seconds') AS hour",
      'AVG(EXTRACT(EPOCH FROM contacts.forwarded_to_agent - contacts.arrived)) AS avg_duration'
    ].join(',')
    data = answered_contacts.select(select).group('hour')

    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['avg_duration'].round }
    result
  end

  # Returns an array of length 24 where each index corresponds to the hour of the day, and the values to the number of calls
  # during that hour
  def calls_by_hour
    gmt_offset = Time.now.getlocal.gmt_offset
    select = "EXTRACT(HOUR FROM contacts.arrived + '#{gmt_offset} seconds') AS hour, COUNT(*) AS count"
    data = answered_contacts.select(select).group('hour')

    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['count'] }
    result
  end

  # Returns the percentage of calls that were answered within the specified time limit
  def service_level_agreement_percentage(time_limit)
    all = num_answered_calls + num_missed_calls
    return 100.0 if all == 0
    answered_in_time = answered_contacts.select("EXTRACT(EPOCH FROM contacts.answered - contacts.arrived) AS duration")
                                        .select { |c| c if c['duration'] < time_limit }
                                        .count
    (answered_in_time.to_f / all * 100).round(1)
  end

  def seconds_since_midnight(time)
    time.hour * 3600 + time.min * 60 + time.sec
  end

  def queue_durations_by_times
    gmt_offset = Time.now.getlocal.gmt_offset
    @contacts.pluck(:arrived, :forwarded_to_agent)
             .map { |d| [seconds_since_midnight(d[0]) + gmt_offset, d[1] - d[0]] unless d[1].nil? }
             .compact
             .select { |s| !s.nil? && s[1] != 0.0 }
             .sort
  end

  def missed_calls_by_hour
    gmt_offset = Time.now.getlocal.gmt_offset
    select = "EXTRACT(HOUR FROM contacts.arrived + '#{gmt_offset} seconds') AS hour, COUNT(*) AS count"
    data = missed_contacts.select(select).group('hour')

    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['count'] }
    result
  end

  # Contacts waiting in queue to be answered
  def queue_contacts
    @contacts.where(contact_type: 'PBX', direction: 'I', forwarded_to_agent: nil, call_ended: nil).where.not(service_id: 120)
  end

  private

  # Contacts that have been completely handled
  def closed_contacts
    @contacts.where(contact_type: 'PBX').where.not(call_ended: nil, answered: nil, service_id: 120, after_call_ended: nil)
  end

  # Contacts that have finished, but after call may still be ongoing
  def finished_contacts
    @contacts.where(contact_type: 'PBX').where.not(answered: nil, call_ended: nil, service_id: 120)
  end

  # Contacts that have been answered(and hence won't be missed contacts for sure), but may still be ongoing
  def answered_contacts
    @contacts.where(contact_type: 'PBX').where.not(answered: nil, service_id: 120)
  end

  # Contacts that have been missed for certain
  def missed_contacts
    @contacts.where(contact_type: 'PBX', answered: nil, after_call_ended: nil, direction: 'I').where.not(call_ended: nil, service_id: 120)
  end

  # Returns the average duration, in seconds, between the two specified fields in the specified set of contacts
  # Field names should correspond to column names in the Contacts table (ie. start_field could be answered, end_field call_ended
  # to calculate the average duration of when a call is answered to when the call ends)
  def average_duration(contacts, period_start_field, period_end_field)
    contacts.select("ROUND(AVG(EXTRACT(EPOCH FROM contacts.#{period_end_field}- contacts.#{period_start_field}))) AS avg")[0]['avg'] || 0
  end
end
