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
    QueueItem.where(open: false, label: "Puhelinvaihde", created_at: start_time..end_time)
  end

  def contact_queues(team_name, start_time, end_time)
    queues(team_name, start_time, end_time)
  end
end
