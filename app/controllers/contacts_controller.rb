# Provide API for retrieving Contacts data
class ContactsController < ApplicationController
  before_action :init

  def init
    time = Time.zone.now
    @start_time = time.beginning_of_day
    @end_time = time.end_of_day
    @team = Team.find_by_name('Helpdesk')
    @contacts_service = ContactsService.new(@team, @start_time, @end_time)
  end

  def today
    @contacts_service.contacts_for_team(@team_name, @start_time, @end_time)
  end

  def stats
    render json: {
      answered_calls: @contacts_service.num_answered_calls,
      average_call_duration: @contacts_service.average_call_duration,
      average_after_call_duration: @contacts_service.average_after_call_duration,
      calls_by_hour: @contacts_service.calls_by_hour,
      missed_calls: @contacts_service.num_missed_calls,
      average_missed_call_duration: @contacts_service.average_missed_call_duration,
      answered_percentage: @contacts_service.answered_percentage,
      average_queue_duration: @contacts_service.average_queue_duration,
      average_queue_duration_by_hour: @contacts_service.average_queue_duration_by_hour,
      service_level_agreement: @contacts_service.service_level_agreement_percentage(settings['others']['sla']),
      queue_durations_by_times: @contacts_service.queue_durations_by_times,
      missed_calls_by_hour: @contacts_service.missed_calls_by_hour
    }
  end
end
