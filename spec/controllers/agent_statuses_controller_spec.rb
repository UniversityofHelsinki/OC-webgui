require 'rails_helper'
require Rails.root.to_s + '/app/controllers/agent_statuses_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe AgentStatusesController, type: :controller do
  render_views

  #before(:each) do
  #  Rails.cache.clear
  #end

  it 'agents json should work' do
    expected = [{"agent_id"=>3300170,
                 "name"=>"joku vaan",
                 "team"=>"Hakijapalvelut",
                 "status"=>"Sisäänkirjaus"},

                {:agent_id=>2200044,
                 :name=>"testaus ukko",
                 :team=>"Opiskelijaneuvonta",
                 :status=>"JÄLKIKIRJAUS"},

                {:agent_id=>1100039,
                 :name=>"kolmas test",
                 :team=>"Opiskelijaneuvonta",
                 :status=>"Sisäänkirjaus"}]

    # onko tässä ees järkee
=begin expected_ilman_kaksoispisteitä_ja_name_eikä_full_name =
               [{"agent_id"=>"3300170",
                 "name"=>"joku vaan",
                 "team"=>"Hakijapalvelut",
                 "status"=>"Sisäänkirjaus",
                 "time_in_status"=>"5984"},

                {"agent_id"=>"2200044",
                 "name"=>"testaus ukko",
                 "team"=>"Opiskelijaneuvonta",
                 "status"=>"JÄLKIKIRJAUS",
                 "time_in_status"=>"1805"},

                {"agent_id"=>"1100039",
                 "name"=>"kolmas test",
                 "team"=>"Opiskelijaneuvonta",
                 "status"=>"Sisäänkirjaus",
                 "time_in_status"=>"13616"}]
=end 

    #BackendService.any_instance.stub(:get_agent_online_state).and_return(expected)
    AgentStatus.create(agent_id: 3300170, name: "joku vaan", team: "Hakijapalvelut", status: "Sisäänkirjaus", open: true)
    AgentStatus.create(agent_id: 2200044, name: "testaus ukko", team: "Opiskelijaneuvonta", status: "JÄLKIKIRJAUS", open: true)
    AgentStatus.create(agent_id: 1100039, name: "kolmas test", team: "Opiskelijaneuvonta", status: "Sisäänkirjaus", open: true)
    
    get :index, format: :json
    agents = JSON.parse(response.body)

    expect(agents).to eq(expected)
  end

  it 'agents json should work with empty' do
    expected = []

    #BackendService.any_instance.stub(:get_agent_online_state).and_return(expected)
    
    get :index, format: :json
    agents = JSON.parse(response.body)
    expect(agents).to eq(expected)
  end

end
