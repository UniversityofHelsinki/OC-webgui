# Retrieves queue status information and passes it to QueueUpdater to update as necessary
class TrackQueueItemsJob
  include Now

  def perform
    current = BackendService.new.get_general_queue.map do |data|
      QueueItem.new(service_id: data[:service_id],
                    label: data[:label],
                    time_in_queue: data[:time_in_queue])
    end
    log = JobLog.new('TrackQueueItemsJob')
    log.log_success if QueueUpdater.new(now, log.last_success).update_queue(current)
  end

  def max_run_time
    1.second
  end

  def max_attempts
    1
  end

  def failure(*)
    JobLog.new('TrackQueueItemsJob').log_failure
  end

  def queue_name
    'statuses'
  end
end
