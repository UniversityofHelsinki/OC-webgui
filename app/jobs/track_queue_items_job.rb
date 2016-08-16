# Retrieves the current state of the queue and stores it temporarily in Rails Cache for Controllers to use.
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
    Rails.cache.write('queue_items', queue_items, expires_in: 30.seconds)
  end

  def self.queue_priority
    0
  end

  def self.queue_respond_timeout
    2
  end
end
