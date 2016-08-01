# API for Queue status data
class QueueItemsController < ApplicationController
  def index
    @queue_items = QueueItem.includes(:team, :service).where(open: true)
  end

  before_action :init

  def init
    time = Time.zone.now
    @start_time = time.beginning_of_day
    @end_time = time.end_of_day
    @team_name = 'Helpdesk'
  end
end
