# API for Queue status data
class QueueItemsController < ApplicationController
  include Now

  # Get current state of the queue
  def index
    return render json: BackendService.new.get_general_queue if params['raw']
    contacts_service = ContactsService.new(nil, now.beginning_of_day, now.end_of_day)
    queue_items = contacts_service.queue_contacts.map do |contact|
      {
        id: contact.ticket_id,
        created_at: contact.arrived,
        team: contact.team.name,
        language: contact.service.language
      }
    end
    render json: queue_items
  end
end
