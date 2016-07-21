# API for Queue status data
class QueueItemsController < ApplicationController
  def index
    @queue_items = QueueItem.includes(:team, :service).where(open: true)
  end

  before_action :init

  def init
    @queue_service = QueueService.new
    time = Time.zone.now
    @start_time = time.beginning_of_day
    @end_time = time.end_of_day
    @team_name = 'Helpdesk'
  end

  def stats
    render json: {
      average_waiting_time: @queue_service.average_queueing_duration(@team_name, @start_time, @end_time),
      queue_items_by_hour: @queue_service.queue_items_by_hour(@team_name, @start_time, @end_time)
    }
  end
end
