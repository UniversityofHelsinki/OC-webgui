# Provides a real-time summary of Helpdesk. Could be used by third-party to embed information on a web site.
class HelpdeskController < ApplicationController
  include Now

  def index
    team = Team.find_by_name('Helpdesk')
    contacts_service = ContactsService.new(team, now.beginning_of_day, now.end_of_day)
    all_agents = AgentStatus.joins(:agent).where(open: true, agents: { team_id: team.id })
    free_agents = all_agents.where(status: %w(Sisäänkirjaus Sisäänkirjautuminen))
    render json: {
      agents_online_all: all_agents.count,
      agents_online_free: free_agents.count,
      queue_length: contacts_service.queue_contacts.count,
      average_queue_duration: contacts_service.average_queue_duration
    }
  end
end
