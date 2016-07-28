# API for OC Agent status data
class PersonalStatusController < ApplicationController
  def index
    agent_id = params[:agent_id]

    contacts_service = ContactsService.new(Agent.find_by(agent_id), Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)

    render json: {
      answered_calls: contacts_service.num_answered_calls,
      average_call_duration: contacts_service.average_call_duration,
      average_after_call_duration: contacts_service.average_after_call_duration,
      # calls_by_hour: @contacts_service.calls_by_hour,
      # missed_calls: @contacts_service.num_missed_calls,
      # average_missed_call_duration: @contacts_service.average_missed_call_duration,
      # answered_percentage: @contacts_service.answered_percentage,
      # average_queue_duration: @contacts_service.average_queue_duration
    }
  end
end
