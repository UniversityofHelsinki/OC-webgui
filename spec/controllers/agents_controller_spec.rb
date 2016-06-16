require "rails_helper"
require_relative "../../app/controllers/agents_controller.rb"
require_relative "../../app/controllers/application_controller.rb"
require_relative "../../app/services/backend_service.rb"

RSpec.describe AgentsController, type: :controller do
  it 'get agent online state should work' do
    expected = [{:agent_id=>"3300170",
                 :full_name=>"joku vaan",
                 :team=>"Hakijapalvelut",
                 :status=>"Sisäänkirjaus",
                 :time_in_status=>"5984"},

                {:agent_id=>"2200044",
                 :full_name=>"testaus ukko",
                 :team=>"Opiskelijaneuvonta",
                 :status=>"JÄLKIKIRJAUS",
                 :time_in_status=>"1805"},

                {:agent_id=>"1100039",
                 :full_name=>"kolmas test",
                 :team=>"Opiskelijaneuvonta",
                 :status=>"Sisäänkirjaus",
                 :time_in_status=>"13616"}]

    BackendService.any_instance.stub(:get_agent_online_state).and_return(expected)
    agents = AgentsController.new
    expect(agents.index[0][:name]).to eq("joku vaan")
    expect(agents.index[1][:name]).to eq("testaus ukko")
    expect(agents.index[2][:name]).to eq("kolmas test")
  end
end

