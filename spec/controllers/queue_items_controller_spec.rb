require 'rails_helper'
require Rails.root.to_s + '/app/controllers/queue_items_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe QueueItemsController, type: :controller do
  render_views

  before do
    allow_any_instance_of(Now).to receive(:now).and_return(Time.utc(2016, 8, 10))
  end

  context 'has queue' do
    before(:each) do
      Team.create(id: 1, name: 'Team A')
      Team.create(id: 2, name: 'Team B')

      Service.create(id: 136, name: 'A', team_id: 1, language: 'English')
      Service.create(id: 133, name: 'B', team_id: 2, language: 'Finnish')

      # Contacts in queue
      Contact.create(ticket_id: '123',
                     service_id: 136,
                     direction: 'I',
                     contact_type: 'PBX',
                     arrived: Time.utc(2016, 8, 10, 9))
      Contact.create(ticket_id: '321',
                     service_id: 133,
                     direction: 'I',
                     contact_type: 'PBX',
                     arrived: Time.utc(2016, 8, 10, 9, 5))

      # Answered contact
      Contact.create(ticket_id: 'abc',
                     service_id: 133,
                     direction: 'I',
                     contact_type: 'PBX',
                     arrived: Time.utc(2016, 8, 10, 9, 5),
                     forwarded_to_agent: Time.utc(2016, 8, 10, 9, 10))

      # Missed contact
      Contact.create(ticket_id: 'cba',
                     service_id: 133,
                     direction: 'I',
                     contact_type: 'PBX',
                     arrived: Time.utc(2016, 8, 10, 9, 5),
                     call_ended: Time.utc(2016, 8, 10, 9, 10))
    end

    it 'returns queue items' do
      expected = [
        {
          'id' => '123',
          'created_at' => '2016-08-10T09:00:00.000Z',
          'team' => 'Team A',
          'language' => 'English'
        },
        {
          'id' => '321',
          'created_at' => '2016-08-10T09:05:00.000Z',
          'team' => 'Team B',
          'language' => 'Finnish'
        }
      ]
      get :index, format: :json
      expect(JSON.parse(response.body)).to eq(expected)
    end
  end

  context 'no queue' do
    it 'returns empty array' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_empty
    end
  end
end
