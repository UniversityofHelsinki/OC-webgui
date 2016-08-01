require 'rails_helper'
require Rails.root.to_s + '/app/controllers/agent_statuses_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe AgentStatusesController, type: :controller do
  render_views

  it 'should return currently open agent statuses in JSON format and ignore non-open statuses' do
    expected = [
      {
        'id' => 3_300_170,
        'first_name' => 'vaan',
        'last_name' => 'joku',
        'status' => 'Vapaa',
        'created_at' => '2016-07-11T10:00:16.000Z',
        'lunch' => false,
        'team' => {
          'id' => 1,
          'name' => 'Hakijapalvelut'
        }
      },
      {
        'id' => 2_200_044,
        'first_name' => 'ukko',
        'last_name' => 'testaus',
        'status' => 'Jälkikirjaus',
        'created_at' => '2016-07-11T10:32:44.000Z',
        'lunch' => false,
        'team' => {
          'id' => 2,
          'name' => 'Opiskelijaneuvonta'
        }
      },
      {
        'id' => 1_100_039,
        'first_name' => 'test',
        'last_name' => 'kolmas',
        'status' => 'JokuSyy',
        'created_at' => '2016-07-11T11:10:05.000Z',
        'lunch' => false,
        'team' => {
          'id' => 2,
          'name' => 'Opiskelijaneuvonta'
        }
      }
    ]

    Team.delete_all
    team1 = Team.create(id: 1, name: 'Hakijapalvelut')
    team2 = Team.create(id: 2, name: 'Opiskelijaneuvonta')
    team3 = Team.create(id: 3, name: 'Helpdesk')

    agent1 = Agent.create(id: 3_300_170, first_name: 'vaan', last_name: 'joku', team: team1)
    agent2 = Agent.create(id: 2_200_044, first_name: 'ukko', last_name: 'testaus', team: team2)
    agent3 = Agent.create(id: 1_100_039, first_name: 'test', last_name: 'kolmas', team: team2)
    agent4 = Agent.create(id: 2_525_208, first_name: 'oleva', last_name: 'kiinni', team: team3)

    AgentStatus.create(agent: agent1, status: 'Sisäänkirjautuminen', open: true, created_at: Time.utc(2016, 7, 11, 10, 0, 16))
    AgentStatus.create(agent: agent2, status: 'Jälkikirjaus', open: true, created_at: Time.utc(2016, 7, 11, 10, 32, 44))
    AgentStatus.create(agent: agent3, status: 'Varattu (JokuSyy)', open: true, created_at: Time.utc(2016, 7, 11, 11, 10, 5))
    AgentStatus.create(agent: agent4, status: 'Vapaa', open: false, created_at: Time.utc(2016, 7, 11, 12, 0))

    get :index, format: :json
    agents = JSON.parse(response.body)

    expect(agents).to eq(expected)
  end

  it 'should return empty array if no open agent statuses exist' do
    get :index, format: :json
    agents = JSON.parse(response.body)
    expect(agents).to be_empty
  end
end
