# API for OC Agent status data
class PersonalStatusController < ApplicationController
  def index
    unless current_user
      render json: { error: 'Please log in to access this resouce' }, status: 403
      return
    end
    agent = Agent.find_by(id: current_user.agent_id)
    if agent.nil?
      render json: { error: 'Current user does not match any registered agent'}, status: 400
      return
    end

    contacts_service = ContactsService.new(Agent.find_by(id: agent.id), Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
    own_status = AgentStatus.find_by(open: true, agent_id: agent.id) || AgentStatus.new(status: 'Ei kirjautunut')

    render json: {
      answered_calls: contacts_service.num_answered_calls,
      average_call_duration: contacts_service.average_call_duration,
      average_after_call_duration: contacts_service.average_after_call_duration,
      own_status: own_status.status
    }
  end
end
