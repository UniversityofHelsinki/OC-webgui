# Provide API for retrieving Contacts data
class ContactsController < ApplicationController
  def today
    @contacts = ContactsService.new.contacts_for_team('Helpdesk', "#{Time.zone.today.beginning_of_day}", "#{Time.zone.today.end_of_day}")
  end
end
