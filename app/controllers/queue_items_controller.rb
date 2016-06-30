# API for Queue status data
class QueueItemsController < ApplicationController
  def index
    @queue_items = Rails.cache.fetch('get_general_queue', expires_in: 5.seconds) do
      BackendService.new.get_general_queue.map do |data|
        QueueItem.new(line: data[:line],
                      label: data[:label],
                      time_in_queue: data[:time_in_queue])
      end
    end
  end
end
