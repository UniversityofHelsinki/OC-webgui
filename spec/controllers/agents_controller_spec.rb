require 'rails_helper'
require Rails.root.to_s + '/app/controllers/agents_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe AgentsController, type: :controller do
  render_views

  before(:each) do
    Rails.cache.clear
  end

  it 'agents json should work' do
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

    # onko tässä ees järkee
    expected_ilman_kaksoispisteitä_ja_name_eikä_full_name =
               [{"agent_id"=>3300170,
                 "name"=>"joku vaan",
                 "team"=>"Hakijapalvelut",
                 "status"=>"Sisäänkirjaus",
                 "time_in_status"=>5984},

                {"agent_id"=>2200044,
                 "name"=>"testaus ukko",
                 "team"=>"Opiskelijaneuvonta",
                 "status"=>"JÄLKIKIRJAUS",
                 "time_in_status"=>1805},

                {"agent_id"=>1100039,
                 "name"=>"kolmas test",
                 "team"=>"Opiskelijaneuvonta",
                 "status"=>"Sisäänkirjaus",
                 "time_in_status"=>13616}]

    BackendService.any_instance.stub(:get_agent_online_state).and_return(expected)
    
    get :index, format: :json
    agents = JSON.parse(response.body)

    # json tiedostossa on id attribuutti?? entiiämiks no tää poistaa sen
    agents.each do |agent|
      agent.delete("id")
    end

    expect(agents).to eq(expected_ilman_kaksoispisteitä_ja_name_eikä_full_name)
  end

  it 'agents json should work with empty' do
    expected = []

    BackendService.any_instance.stub(:get_agent_online_state).and_return(expected)
    
    get :index, format: :json
    agents = JSON.parse(response.body)
    puts "mrklgtmhlmk"
    puts agents
    expect(agents).to eq(expected)
  end

end
