# Provide API for retrieving Contacts data
class ContactsController < ApplicationController
  def today
    ContactsService.new.contacts_for_team('Helpdesk', Time.zone.today.beginning_of_day, Time.zone.today.end_of_day)
  end

  def stats
    render json: {
      answered_calls: ContactsService.new.answered_calls('Helpdesk', Time.zone.today.beginning_of_day, Time.zone.today.end_of_day),
      average_call_duration: ContactsService.new.average_call_duration('Helpdesk', Time.zone.today.beginning_of_day, Time.zone.today.end_of_day),
      average_after_call_duration: ContactsService.new.average_after_call_duration('Helpdesk', Time.zone.today.beginning_of_day, Time.zone.today.end_of_day)
    }
  end
end
