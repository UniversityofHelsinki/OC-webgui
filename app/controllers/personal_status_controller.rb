# API for OC Agent status data
class PersonalStatusController < ApplicationController
  def index
    user = User.find_by(id: session[:user_id])
    agent_id = user.agent_id
    if agent_id.nil?
      render json: {}, status: 404
      return
    end
    agent = Agent.find_by(id: agent_id)
    if agent.nil?
      render json: {}, status: 403
      return
    end

    contacts_service = ContactsService.new(Agent.find_by(id: agent_id), Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)

    render json: {
      answered_calls: contacts_service.num_answered_calls,
      average_call_duration: contacts_service.average_call_duration,
      average_after_call_duration: contacts_service.average_after_call_duration
    }
  end
end
