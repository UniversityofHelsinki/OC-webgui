RSpec.describe AgentsController, type: :controller do
  render_views

  it "returns all current agents in index" do
    allow_any_instance_of(AgentsController).to receive(:fetch_and_save_all_agents).and_return(nil)
    a_team = Team.create(id: 1, name: 'A-Team')
    Agent.create(id: 1, first_name: "keke", last_name: "x", team: a_team)
    Agent.create(id: 2, first_name: "spede", last_name: "x", team: a_team)
    get :index, format: :json
    agent1 = {
      "id"=>1,
      "first_name"=>"keke",
      "last_name"=>"x",
      "team"=>{
        "id"=>1,
        "name"=>"A-Team"
      }
    }
    agent2 = {
      "id"=>2,
      "first_name"=>"spede",
      "last_name"=>"x",
      "team"=>{
        "id"=>1,
        "name"=>"A-Team"
      }
    }
    expect(JSON.parse(response.body)).to include(agent1)
    expect(JSON.parse(response.body)).to include(agent2)
  end

  it "returns all current agents in index and new found from soap" do
    Team.create(id: 1, name: 'Helpdesk')
    Team.create(id: 2, name: 'Puhelinvaihde')
    agents_map = [{:first_name => "keke",
                   :last_name => "x",
                   :agent_id => 1,
                   :team_name => "Helpdesk"},
                  {:first_name => "spede",
                   :last_name => "x",
                   :agent_id => 2,
                   :team_name => "Helpdesk"},
                  {:first_name => "harri",
                   :last_name => "x",
                   :agent_id => 3,
                   :team_name => "Puhelinvaihde"}]
    allow_any_instance_of(BackendService).to receive(:get_agents).and_return(agents_map)
    Agent.create(id: 1, first_name: "keke", last_name: "x")
    Agent.create(id: 2, first_name: "spede", last_name: "x")
    get :index, format: :json
    agent1 = {
      "id"=>1,
      "first_name"=>"keke",
      "last_name"=>"x",
      "team"=>{
        "id"=>1,
        "name"=>"Helpdesk"
      }
    }
    agent2 = {
      "id"=>2,
      "first_name"=>"spede",
      "last_name"=>"x",
      "team"=>{
        "id"=>1,
        "name"=>"Helpdesk"
      }
    }
    agent3 = {
      "id"=>3,
      "first_name"=>"harri",
      "last_name"=>"x",
      "team"=>{
        "id"=>2,
        "name"=>"Puhelinvaihde"
      }
    }
    expect(JSON.parse(response.body)).to include(agent1)
    expect(JSON.parse(response.body)).to include(agent2)
    expect(JSON.parse(response.body)).to include(agent3)
  end
end
