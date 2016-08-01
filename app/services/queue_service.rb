# Provides functionality for statistical data about the Queue
class QueueService
  def average_queueing_duration(team_name, start_time, end_time)
    average_duration(contact_queue_items(team_name, start_time, end_time))
  end

  def queue_items_by_hour(team_name, start_time, end_time)
    gmt_offset = Time.now.getlocal.gmt_offset
    select = "EXTRACT(HOUR FROM queue_items.created_at + '#{gmt_offset} seconds') AS hour, COUNT(*) AS count"
    data = contact_queue_items(team_name, start_time, end_time).select(select).group('hour')
    result = Array.new(24, 0)
    data.each { |d| result[(d['hour'])] = d['count'] }
    result
  end

# not used
=begin
  def average_queueing_duration_by_hour(team_name, start_time, end_time)
    gmt_offset = Time.now.getlocal.gmt_offset
    (0..23).map do |i|
      h = start_time.beginning_of_day + i.hour - gmt_offset
      average_queueing_duration(team_name, h, h + 59.minutes + 59.seconds)
    end
  end
=end

  private

  def contact_queue_items(team_name, start_time, end_time)
    queue_items(team_name, start_time, end_time)
  end

  def average_duration(queue_items)
    queue_items.select('ROUND(AVG(EXTRACT(EPOCH FROM closed - queue_items.created_at))) AS average_duration')[0]['average_duration'] || 0
  end

  def queue_items(team_name, start_time, end_time)
    QueueItem.joins(service: :team).where(open: false, teams: { name: team_name }, created_at: start_time..end_time)
  end
end
