require "rails_helper"
require_relative "../../app/controllers/agents_controller.rb"
require_relative "../../app/controllers/application_controller.rb"

RSpec.describe AgentsController, type: :controller do
  let(:agent) {
      Agent.create!(:agent_id => '23',
                    :name => 'Alice',
                    :team => 'testi',
                    :status => 'SISÄÄNKIRJAUS',
                    :time_in_status => '34')
  }

  context "#to_json" do
    it "includes names" do
      agents = %({"id":1,"agent_id":23,"name":"Alice","team":"testi","status":"SISÄÄNKIRJAUS","time_in_status":34})
      expect(agent.to_json).to be_json_eql(agents)
    end
  end

  it 'Content-type should be json' do
    # TODO ei kovin hyvä tapa
    get :index, use_route: :agents, format: :json 
    expect(response.header['Content-Type']).to include 'application/json'
  end
end

