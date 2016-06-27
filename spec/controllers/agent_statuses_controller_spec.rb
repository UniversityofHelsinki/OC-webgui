require 'rails_helper'
require Rails.root.to_s + '/app/controllers/agent_statuses_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe AgentStatusesController, type: :controller do
  render_views

  it 'should return currently open agent statuses in JSON format and ignore non-open statuses' do
    agent1 = {"agent_id"=>3300170,
       "name"=>"joku vaan",
       "team"=>"Hakijapalvelut",
       "status"=>"Sisäänkirjaus",
       "created_at"=>anything }

    agent2 = {"agent_id"=>2200044,
        "name"=>"testaus ukko",
        "team"=>"Opiskelijaneuvonta",
        "status"=>"Jälkikirjaus",
        "created_at"=>anything }

    agent3= {"agent_id"=>1100039,
        "name"=>"kolmas test",
        "team"=>"Opiskelijaneuvonta",
        "status"=>"Sisäänkirjaus",
        "created_at"=>anything }

    agent4= {"agent_id"=>2525208,
        "name"=>"kiinnioleva",
        "team"=>"Helpdesk",
        "status"=>"Sisäänkirjaus",
        "created_at"=>anything }


    AgentStatus.create(agent_id: 3300170, name: "joku vaan", team: "Hakijapalvelut", status: "Sisäänkirjaus", open: true)
    AgentStatus.create(agent_id: 2200044, name: "testaus ukko", team: "Opiskelijaneuvonta", status: "Jälkikirjaus", open: true)
    AgentStatus.create(agent_id: 1100039, name: "kolmas test", team: "Opiskelijaneuvonta", status: "Sisäänkirjaus", open: true)
    AgentStatus.create(agent_id: 2525208, name: "kiinnioleva", team: "Helpdesk", status: "Sisäänkirjaus", open: false)

    
    get :index, format: :json
    agents = JSON.parse(response.body)

    expect(agents).to include(agent1)
    expect(agents).to include(agent2)
    expect(agents).to include(agent3)
    expect(agents).not_to include(agent4)

  end

  it 'should return empty array if no open agent statuses exist' do

    get :index, format: :json
    agents = JSON.parse(response.body)
    expect(agents).to be_empty
  end

end
