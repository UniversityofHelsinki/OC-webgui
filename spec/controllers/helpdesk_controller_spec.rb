require 'rails_helper'
require Rails.root.to_s + '/app/controllers/helpdesk_controller.rb'
require Rails.root.to_s + '/app/controllers/contacts_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe HelpdeskController, type: :controller do
  render_views

  before (:each) do
    allow(Time).to receive(:now) { Time.utc(2016, 8, 10) }

    team2 = Team.create(id: 1, name: 'Hakijapalvelut')
    team2 = Team.create(id: 2, name: 'Opiskelijaneuvonta')
    team3 = Team.create(id: 3, name: 'Helpdesk')

    agent1 = Agent.create(id: 3_300_170, first_name: 'vaan', last_name: 'joku', team: team3)
    agent2 = Agent.create(id: 2_200_044, first_name: 'ukko', last_name: 'testaus', team: team2)
    agent3 = Agent.create(id: 1_100_039, first_name: 'test', last_name: 'kolmas', team: team3)
    agent4 = Agent.create(id: 2_525_208, first_name: 'oleva', last_name: 'kiinni', team: team3)

    AgentStatus.create(agent: agent1, status: 'Sisäänkirjautuminen', open: true, created_at: Time.utc(2016, 7, 11, 10, 0, 16))
    AgentStatus.create(agent: agent2, status: 'Jälkikirjaus', open: true, created_at: Time.utc(2016, 7, 11, 10, 32, 44))
    AgentStatus.create(agent: agent3, status: 'Varattu (JokuSyy)', open: true, created_at: Time.utc(2016, 7, 11, 11, 10, 5))
    AgentStatus.create(agent: agent4, status: 'Vapaa', open: false, created_at: Time.utc(2016, 7, 11, 12, 0))

    Service.create(id: 123, language: 'Finnish', team: team3)
    Service.create(id: 321, language: 'English', team: team3)

    Contact.create(ticket_id: '123',
                   service_id: 123,
                   direction: 'I',
                   contact_type: 'PBX',
                   arrived: Time.utc(2016, 8, 10, 9))
    Contact.create(ticket_id: '321',
                   service_id: 321,
                   direction: 'I',
                   contact_type: 'PBX',
                   arrived: Time.utc(2016, 8, 10, 9, 5))

    allow_any_instance_of(ContactsService).to receive(:average_queue_duration).and_return(301.0)
  end

  context 'no queue' do
    it 'returns empty array' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to eq({"agents_online_all"=>2, "agents_online_free"=>1, "queue_count"=>2, "average_queue_duration"=>301.0})
    end
  end
end
