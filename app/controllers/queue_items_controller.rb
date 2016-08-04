# API for Queue status data
class QueueItemsController < ApplicationController
  def index
    return render json: [] if Rails.cache.read('queue_items').nil?
    render json: Rails.cache.read('queue_items')
  end

  before_action :init

  def init
    time = Time.zone.now
    @start_time = time.beginning_of_day
    @end_time = time.end_of_day
    @team_name = 'Helpdesk'
  end
end
