require 'rails_helper'
require 'savon/mock/spec_helper'
require Rails.root.to_s + '/app/services/backend_service.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'

RSpec.describe BackendService, type: :service do
  include Savon::SpecHelper

  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }

  it "get_agent_online_state should work if 4 people are online" do
    fixture = File.read("spec/fixtures/backend_service/get_agent_online_state_length_4.xml")
    expected = [
      {:agent_id=>"1000081", :name=>"Korhonen Matti", :team=>"Helpdesk", :status=>"Backoffice", :time_in_status=>"2565"},
      {:agent_id=>"1000021", :name=>"Virtanen Timo", :team=>"Opiskelijaneuvonta", :status=>"Sisäänkirjaus", :time_in_status=>"15068"},
      {:agent_id=>"1000061", :name=>"Mäkinen Kari", :team=>"Opiskelijaneuvonta", :status=>"Tauko", :time_in_status=>"141"},
      {:agent_id=>"1000041", :name=>"Nieminen Antti", :team=>"Helpdesk", :status=>"Jälkikirjaus", :time_in_status=>"425"}
    ]
    savon.expects(:get_agent_online_state).returns(fixture)
    response = BackendService.new.get_agent_online_state
    expect(response).to eq(expected)
  end

  it "get_agent_online_state should return empty arrayt if no one is working" do
    fixture = File.read("spec/fixtures/backend_service/empty_get_agent_online_state.xml")
    savon.expects(:get_agent_online_state).returns(fixture)
    response = BackendService.new.get_agent_online_state
    expect(response).to be_empty
  end

  it "get_agent_online_state should return array of length 1 if only 1 is working" do
    fixture = File.read("spec/fixtures/backend_service/get_agent_online_state_length_1.xml")
    expected = [
      {:agent_id=>"1000081", :name=>"Korhonen Matti", :team=>"Helpdesk", :status=>"Backoffice", :time_in_status=>"2565"}
    ]
    savon.expects(:get_agent_online_state).returns(fixture)
    response = BackendService.new.get_agent_online_state
    expect(response).to eq(expected)
    expect(response.length).to eq(1)
  end

  it "get_agent_online_state should work even if soap provider is down (http error 500)" do   
    response = {code: 500, headers: {}}
    savon.expects(:get_agent_online_state).returns(response)
    response = BackendService.new.get_agent_online_state
    expect(response).to be_empty
  end

  it "queue should return empty array if queue is empty" do
    fixture = File.read("spec/fixtures/backend_service/empty_queue.xml")
    savon.expects(:get_general_queue).returns(fixture)
    response = BackendService.new.get_general_queue
    expect(response).to be_empty
  end

  it "queue should return 1 queuer if length of queue is 1" do
    fixture = File.read("spec/fixtures/backend_service/get_general_queue_length_1.xml")
    savon.expects(:get_general_queue).returns(fixture)
    response = BackendService.new.get_general_queue
    expect(response.length).to eq(1)
  end

  it "queue should return 2 queuer if length of queue is 2" do
    fixture = File.read("spec/fixtures/backend_service/get_general_queue_length_2.xml")
    savon.expects(:get_general_queue).returns(fixture)
    response = BackendService.new.get_general_queue
    expect(response.length).to eq(2)
  end

=begin
  it "get_teams should return array of 3 if there exists 3 teams" do
    fixture = File.read("spec/fixtures/backend_service/get_teams_length_3.xml")
    expected = ["Väinämöinen", "Joukahainen", "Aino"]
    savon.expects(:get_teams).returns(fixture)
    response = BackendService.new.get_teams
    expect(response).to eq(expected)
  end

  it "get_teams should return array of 1 if there exists 1 team" do
    fixture = File.read("spec/fixtures/backend_service/get_teams_length_1.xml")
    expected = ["Joukahainen"]
    savon.expects(:get_teams).returns(fixture)
    response = BackendService.new.get_teams
    expect(response).to eq(expected)
  end

  it "get_teams should return empty array if there are no teams" do
    fixture = File.read("spec/fixtures/backend_service/empty_get_teams.xml")
    savon.expects(:get_teams).returns(fixture)
    response = BackendService.new.get_teams
    expect(response).to be_empty
  end
=end
end
