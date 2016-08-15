RSpec.describe AgentsController, type: :controller do
  render_views

  it "returns all current agents in index" do
    Agent.create(id: 1, first_name: "keke", last_name: "x")
    Agent.create(id: 2, first_name: "spede", last_name: "x")
    get :index, format: :json
    agent1 = {
      "id"=>1,
      "first_name"=>"keke",
      "last_name"=>"x",
    }
    agent2 = {
      "id"=>2,
      "first_name"=>"spede",
      "last_name"=>"x"
    }
    allow_any_instance_of(AgentsController).to receive(:get_all).and_return(nil)
    expect(JSON.parse(response.body)).to include(agent1)
    expect(JSON.parse(response.body)).to include(agent2)
  end
end
