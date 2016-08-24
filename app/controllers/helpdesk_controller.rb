class HelpdeskController < ApplicationController
  before_action :init

  def init
    time = Time.zone.now
    @start_time = time.beginning_of_day
    @end_time = time.end_of_day
    @team = Team.find_by_name('Helpdesk')
    @contacts_service = ContactsService.new(@team, @start_time, @end_time)
    @agent_statuses = AgentStatus.joins(:agent).where(open: true, agents: { team_id: Team.find_by_name('Helpdesk').id })
  end

  def free_agents
    @agent_statuses.where(status: ['Sisäänkirjaus', 'Sisäänkirjautuminen'])
  end

  def queuers_count
    BackendService.new.get_general_queue.inject (0) do |sum, data|
      sum += 1 if Service.find(data[:service_id]).team.name == 'Helpdesk'
    end
  end

  def index
    render json: {
      agents_online_all: @agent_statuses.length,
      agents_online_free: free_agents.length,
      queue_count: queuers_count,
      average_queue_duration: @contacts_service.average_queue_duration
    }
  end
end
