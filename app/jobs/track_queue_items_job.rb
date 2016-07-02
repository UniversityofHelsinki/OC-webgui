# Retrieves quque status information and passes it to QueueUpdater to update as necessary
class TrackQueueItemsJob
  def perform
    current = BackendService.new.get_general_queue.map do |data|
      QueueItem.new(line: data[:line],
                    label: data[:label],
                    time_in_queue: data[:time_in_queue])
    end
    QueueUpdater.new(Time.zone.now, JobLog.new('TrackQueueItemsJob').last_success).update_queue(current)
  end

  def max_run_time
    2.seconds
  end

  def max_attempts
    1
  end

  def success(job)
    JobLog.new('TrackQueueItemsJob').log_success
  end

  def failure(job)
    JobLog.new('TrackQueueItemsJob').log_failure
  end
end
