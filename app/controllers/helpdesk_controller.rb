class HelpdeskController < ApplicationController
  before_action :init

  def init
    time = Time.zone.now
    @start_time = time.beginning_of_day
    @end_time = time.end_of_day
    @team = Team.find_by_name('Helpdesk')
    @contacts_service = ContactsService.new(@team, @start_time, @end_time)
    @agent_statuses = AgentStatus.joins(:agent).where(open: true, agents: { team_id: @team.id })
  end

  def free_agents
    @agent_statuses.where(status: ['Sisäänkirjaus', 'Sisäänkirjautuminen'])
  end

  def queuer_length
    @contacts_service.queue_contacts.length
  end

  def index
    render json: {
      agents_online_all: @agent_statuses.length,
      agents_online_free: free_agents.length,
      queue_length: queue_length,
      average_queue_duration: @contacts_service.average_queue_duration
    }
  end
end
