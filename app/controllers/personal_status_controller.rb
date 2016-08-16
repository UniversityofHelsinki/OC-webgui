# API for OC Agent status data
class PersonalStatusController < ApplicationController
  before_action :ensure_user_is_logged_in, only: :index

  # Statistics for the current day for the currently logged in user
  def index
    if current_user.agent.nil?
      render json: { error: 'Current user does not match any registered agent' }, status: 400
      return
    end
    contacts_service = ContactsService.new(current_user.agent, Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
    render json: {
      answered_calls: contacts_service.num_answered_calls,
      average_call_duration: contacts_service.average_call_duration,
      average_after_call_duration: contacts_service.average_after_call_duration
    }
  end
end
