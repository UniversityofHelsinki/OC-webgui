# Calculates various statistics data based on Contact objects.
class ContactsService
  def initialize(filter_by_model, start_time, end_time)
    @gmt_offset = Time.now.getlocal.gmt_offset
    @start_time = start_time
    if filter_by_model.is_a? Team
      @contacts = Contact.joins(:service).where(services: { team_id: filter_by_model.id }, arrived: start_time..end_time)
    elsif filter_by_model.is_a? Agent
      @contacts = Contact.where(agent: filter_by_model, arrived: start_time..end_time)
    end
  end

  def num_answered_calls
    answered_contacts.count
  end

  def average_call_duration
    average_duration(answered_contacts, 'answered', 'call_ended')
  end

  def average_after_call_duration
    contacts = @contacts.where(contact_type: 'PBX').where.not(call_ended: nil, answered: nil, service_id: 120, after_call_ended: nil)
    average_duration(contacts, 'call_ended', 'after_call_ended')
  end

  def answered_percentage
    answered = num_answered_calls
    missed = num_missed_calls
    return 100.0 if (answered + missed) == 0
    (answered.to_f / (answered + missed) * 100).round(1)
  end

  def num_missed_calls
    missed_contacts.count
  end

  def average_missed_call_duration
    average_duration(missed_contacts, 'arrived', 'call_ended')
  end

  def average_queue_duration
    contacts = @contacts.where(contact_type: 'PBX').where.not(forwarded_to_agent: nil, service_id: 120)
    average_duration(contacts, 'arrived', 'forwarded_to_agent')
  end

  def average_queue_duration_by_hour
    gmt_offset = Time.now.getlocal.gmt_offset
    select = [
      "EXTRACT(HOUR FROM contacts.arrived + '#{gmt_offset} seconds') AS hour",
      'AVG(EXTRACT(EPOCH FROM contacts.forwarded_to_agent - contacts.arrived)) AS avg_duration'
    ].join(',')
    data = answered_contacts.select(select).group('hour')

    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['avg_duration'] }
    result
  end

  def calls_by_hour
    gmt_offset = Time.now.getlocal.gmt_offset
    select = "EXTRACT(HOUR FROM contacts.arrived + '#{gmt_offset} seconds') AS hour, COUNT(*) AS count"
    data = answered_contacts.select(select).group('hour')

    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['count'] }
    result
  end

  def queue_durations_by_times
    @contacts.pluck(:arrived, :forwarded_to_agent)
             .map { |d| [d[0], d[1] - d[0]] unless d[1].nil? }
             .compact
             .select { |s| !s.nil? && s[1] != 0.0 }
             .sort
  end

  def correlation_of_average_queue_length_and_missed_calls
    if @start_time.is_a? String
      beginning = Time.zone.parse(@start_time).beginning_of_day if @start_time.is_a? String
    else
      beginning = @start_time.beginning_of_day
    end

    stats = []
    # gmt offset
    48.times do
      beginning += 30.minutes
      ending = beginning + 29.minutes + 59.seconds
      missed = missed_contacts.where(arrived: beginning..ending).count
      answered = answered_contacts.where(arrived: beginning..ending).count
      sum = missed + answered
      queuers = @contacts.where(contact_type: 'PBX')
                         .where.not(forwarded_to_agent: nil, service_id: 120)
                         .where(arrived: beginning..ending)
      queue_average = average_duration(queuers, 'arrived', 'forwarded_to_agent')
      stats.push([beginning, sum, missed, queue_average])
      # TODO thinkin shud begining variable be change here and not in beginning
    end

    stats
  end

  private

  def answered_contacts
    @contacts.where(contact_type: 'PBX').where.not(call_ended: nil, answered: nil, service_id: 120)
  end

  def missed_contacts
    @contacts.where(contact_type: 'PBX', answered: nil, after_call_ended: nil, direction: 'I').where.not(call_ended: nil, service_id: 120)
  end

  def average_duration(contacts, period_start_field, period_end_field)
    contacts.select("ROUND(AVG(EXTRACT(EPOCH FROM contacts.#{period_end_field}- contacts.#{period_start_field}))) AS avg")[0]['avg'] || 0
  end
end
