# Retrieves queue status information and passes it to QueueUpdater to update as necessary
class TrackQueueItemsJob
  extend Now

  def self.perform
    queue_items = BackendService.new.get_general_queue.map do |data|
      service = Service.find(data[:service_id])
      {
        team: service.team.name,
        language: service.language,
        time_in_queue: data[:time_in_queue]
      }
    end
    Rails.cache.write('queue_items', queue_items)
  end

  def self.queue_priority
    0
  end

  def self.queue_respond_timeout
    2
  end
end
