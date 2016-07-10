class QueueService
  def initialize
  end

  def average_queueing_duration(team_name, start_time, end_time)
    average_duration(contact_queues(team_name, start_time, end_time))
  end

  def average_duration(queues)
    queues.select('ROUND(AVG(EXTRACT(EPOCH FROM closed - created_at))) AS average_duration')[0]['average_duration'] || 0
  end

  def queues(team_name, start_time, end_time)
    QueueItem.where(open: false, label: team_name, created_at: start_time..end_time, closed: start_time..end_time)
  end

  def queues_by_hour(team_name, start_time, end_time)
    gmt_offset = Time.now.getlocal.gmt_offset
    select = "EXTRACT(HOUR FROM created_at + '#{gmt_offset} seconds') AS hour, COUNT(*) AS count"
    data = contact_queues(team_name, start_time, end_time).select(select).group('hour')
    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['count'] }
    result
  end

  def contact_queues(team_name, start_time, end_time)
    queues(team_name, start_time, end_time)
  end
end
