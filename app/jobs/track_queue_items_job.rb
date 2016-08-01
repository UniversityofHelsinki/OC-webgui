# Retrieves queue status information and passes it to QueueUpdater to update as necessary
class TrackQueueItemsJob
  extend Now

  def self.perform
    current = BackendService.new.get_general_queue.map do |data|
      QueueItem.new(service_id: data[:service_id],
                    service_name: data[:service_name],
                    time_in_queue: data[:time_in_queue])
    end
    last_success = Rails.cache.read('track_queue_items_job_last_success')
    QueueUpdater.new(now, last_success).update_queue(current)
    Rails.cache.write('track_queue_items_job_last_success', now)
  end

  def self.queue_priority
    0
  end

  def self.queue_respond_timeout
    2
  end
end
