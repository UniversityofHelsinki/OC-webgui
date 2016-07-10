require 'rails_helper'
require Rails.root.to_s + '/app/controllers/agent_statuses_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe AgentStatusesController, type: :controller do
  render_views

  it 'should return currently open agent statuses in JSON format and ignore non-open statuses' do
    expected_agent1 = {
       "id"=>3300170,
       "first_name"=>"vaan",
       "last_name"=>"joku",
       "status"=>"Vapaa",
       "created_at"=>anything,
       "team"=>{
         "id"=>1,
         "name"=>"Hakijapalvelut"
       }}

    expected_agent2 = {
        "id"=>2200044,
        "first_name"=>"ukko",
        "last_name"=>"testaus",
        "status"=>"Jälkikirjaus",
        "created_at"=>anything,
        "team"=>{
          "id"=>2,
          "name"=>"Opiskelijaneuvonta"
        }}


    expected_agent3= {
        "id"=>1100039,
        "first_name"=>"test",
        "last_name"=>"kolmas",
        "status"=>"Vapaa",
        "created_at"=>anything,
        "team"=>{
          "id"=>2,
          "name"=>"Opiskelijaneuvonta"
        }}

    not_expected_agent= {
        "id"=>2525208,
        "first_name"=>"oleva",
        "last_name"=>"kiinni",
        "status"=>"Vapaa",
        "created_at"=>anything,
        "team"=>{
          "id"=>3,
          "name"=>"Helpdesk"
        }}

    Team.delete_all
    team1 = Team.create(id: 1, name: 'Hakijapalvelut')
    team2 = Team.create(id: 2, name: 'Opiskelijaneuvonta')
    team3 = Team.create(id: 3, name: 'Helpdesk')

    agent1 = Agent.create(id: 3300170, first_name: 'vaan', last_name: 'joku', team: team1)
    agent2 = Agent.create(id: 2200044, first_name: 'ukko', last_name: 'testaus', team: team2)
    agent3 = Agent.create(id: 1100039, first_name: 'test', last_name: 'kolmas', team: team2)
    agent4 = Agent.create(id: 2525208, first_name: 'oleva', last_name: 'kiinni', team: team3)

    AgentStatus.create(agent: agent1, status: "Vapaa", open: true)
    AgentStatus.create(agent: agent2, status: "Jälkikirjaus", open: true)
    AgentStatus.create(agent: agent3, status: "Vapaa", open: true)
    AgentStatus.create(agent: agent4, status: "Vapaa", open: false)

    
    get :index, format: :json
    agents = JSON.parse(response.body)

    expect(agents).to include(expected_agent1)
    expect(agents).to include(expected_agent2)
    expect(agents).to include(expected_agent3)
    expect(agents).not_to include(not_expected_agent)

  end

  it 'should return empty array if no open agent statuses exist' do

    get :index, format: :json
    agents = JSON.parse(response.body)
    expect(agents).to be_empty
  end

end
