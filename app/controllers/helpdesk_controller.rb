class HelpdeskController < ApplicationController
  before_action :init

  def init
    time = Time.zone.now
    @start_time = time.beginning_of_day
    @end_time = time.end_of_day
    @team = Team.find_by_name('Helpdesk')
    @contacts_service = ContactsService.new(@team, @start_time, @end_time)
    @agent_statuses = AgentStatus.where(open: true).joins(agent: :team)
  end

  def free_agents
    return 44
  end

  def index
    render json: {
      agents_online_all: @agent_statuses, # <-- ei toimi huoh
      agents_online_free: free_agents,
      queue_count: BackendService.new.get_general_queue.count,
      average_queue_duration: @contacts_service.average_queue_duration
    }
  end
end
