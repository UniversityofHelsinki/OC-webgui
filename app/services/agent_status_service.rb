# Provides statistics based on Agent Status data
class AgentStatusService
  def initialize(team_name, start_date, end_date)
    start_date = Time.zone.parse(start_date) if start_date.class == String
    end_date = Time.zone.parse(end_date) if end_date.class == String
    # TODO: korjais tän ku on toistoa
    @start_time = start_date.beginning_of_day
    @end_time = end_date.end_of_day
    @statuses = AgentStatus.joins(agent: :team).where(teams: { name: team_name },
                                                      created_at: start_date.beginning_of_day..end_date.end_of_day,
                                                      open: false)
                                               .where('agent_statuses.created_at::date = agent_statuses.closed::date')
                                               .order(:created_at)
  end

  # Returns a hash where the keys are numbers 0-23, corresponding to each hour. For each hour, values are sub-keys free, busy and other,
  # which contain the number of seconds spent in each category of status for that hour, by all agents combined.
  # Since the time period used can pass multiple days, each hour will contain the time cumulatively from all days considered.
  def stats_by_hour
    gmt_offset = Time.now.getlocal.gmt_offset
    stats = {}
    (0..23).each { |i| stats[i] = { free: 0, busy: 0, other: 0 } }
    @statuses.each do |status|
      date = status.created_at.to_date
      start_hour = status.created_at.strftime("%H").to_i + gmt_offset / 3600
      # Since the result should contain time spent in one-hour blocks, if a status lasts longer than one hour it needs to be 
      # stored across multiple hours. Ie: a Status from 09:30-12:20 would be added to totals as 09=>30, 10=>60, 11=>60, 12=>20.
      hours = status.closed.strftime("%H").to_i - status.created_at.strftime("%H").to_i + 1
      type = status_type(status.status)
      hours.times do |i|
        range_start = date + start_hour.hours + i.hours
        stats[start_hour + i][type] += portion_within_range(range_start, range_start + 1.hour, status.created_at + gmt_offset, status.closed + gmt_offset)
      end
    end
    stats.map do |hour, data|
      data.merge({hour: hour})
    end
  end

  def stats_by_day
    gmt_offset = Time.now.getlocal.gmt_offset
    stats = {}

    # initialize result array to contain all dates
    date = @start_time
    while date < @end_time
      stats[date.to_date] = { free: 0, busy: 0, other: 0 }
      date = date + 1.day
    end
    @statuses.each do |status|
      date = status.created_at.to_date
      stats[date][status_type(status.status)] += status.closed - status.created_at
    end
    stats.map do |date, data|
      data.merge({date: date})
    end
  end

  def duration(statuses)
    statuses.inject(0) { |sum, status| sum += status.closed - status.created_at }
  end

  # Determines whether a status counts as free, ie. ready to take calls, busy. ie. taking calls or logging them, or other,
  # ie. on a break/backoffice duty/any other task that isn't taking calls or being ready to receive them.
  def status_type(status)
    case status
    when 'Sisäänkirjautuminen', 'Sisäänkirjaus'
      return :free
    when 'Puhelu', 'Puhelu (Sisään)', 'Varattu (Chat)', 'Chat'
      return :busy
    else
      return :other
    end
  end

  # Returns the portion of the closed - created_at range that is within the range_end - range_start range.
  # Ex: Range_start is 09:00, range_end is 10:00, created_at is 08:45, closed is 09:20. Returns (20 * 60) as
  # the 09:00 - 09:20 part of closed - created_at is within the specified range. 
  def portion_within_range(range_start, range_end, created_at, closed)
    return 0 if created_at > range_end || closed < range_start
    [range_end, closed].min - [range_start, created_at].max    
  end
end
