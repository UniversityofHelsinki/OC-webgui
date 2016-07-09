# API for Queue status data
class QueueItemsController < ApplicationController
  def index
    @queue_items = QueueItem.where(open: true)
  end
end
