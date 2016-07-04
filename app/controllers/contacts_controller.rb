# Provide API for retrieving Contacts data
class ContactsController < ApplicationController
  before_action :init

  def init
    @contacts_service = ContactsService.new
    time = Time.zone.local(2016, 6, 30)
    # time = Time.zone.now
    @start_time = time.beginning_of_day
    @end_time = time.end_of_day
    @team_name = 'Helpdesk'
  end

  def today
    @contacts_service.contacts_for_team(@team_name, @start_time, @end_time)
  end

  def stats
    render json: {
      answered_calls: @contacts_service.answered_calls(@team_name, @start_time, @end_time),
      average_call_duration: @contacts_service.average_call_duration(@team_name, @start_time, @end_time),
      average_after_call_duration: @contacts_service.average_after_call_duration(@team_name, @start_time, @end_time),
      calls_by_hour: @contacts_service.calls_by_hour(@team_name, @start_time, @end_time)
    }
  end
end
