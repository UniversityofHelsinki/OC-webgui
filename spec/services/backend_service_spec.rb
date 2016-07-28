require 'rails_helper'
require 'savon/mock/spec_helper'
require Rails.root.to_s + '/app/services/backend_service.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'

RSpec.describe BackendService, type: :service do
  include Savon::SpecHelper

  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }

  def with_utc_offset(timestamp)
    return nil unless timestamp
    timestamp + Time.now.strftime("%z")
  end

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

  it "Should return one contact from GetAgentsContacts" do
    fixture = File.read("spec/fixtures/backend_service/get_agent_contacts_1.xml")

    message = { serviceGroupID: 4, serviceID: 137, teamID: "Helpdesk",
    agentID: 2000049, startDate: "2016-06-14", endDate: "2016-06-15",
    contactTypes: 'PBX', useServiceTime: false }

    expected = [
      {:ticket_id=>"20160614091049336435", 
:arrived=>with_utc_offset("14.6.2016 9:11:43"), 
:time_in_queue=>"1", 
:forwarded_to_agent=>with_utc_offset("14.6.2016 9:11:44"), 
:answered=>with_utc_offset("14.6.2016 9:11:57"), 
:call_ended=>with_utc_offset("14.6.2016 9:13:59"), 
:after_call_ended=>with_utc_offset("14.6.2016 9:21:41"), 
:total_response_time=>"598", 
:total_handle_time=>"597",
:service_name=>"Neuvonta Fin", 
:direction=>"I", 
:contact_type=>"PBX",
:contact_information=>"0405882759", 
:agent_name=>"Seppänen Pekka", 
:customer_id=>"-1",
:contact_reason=>"Onnistunut kontakti", 
:information=>"nil",
:ivr_feedback=>"-1",
:category_of_recording=>nil,
:recorded=>nil,
:inserted_to_db=>nil,
:task_count=>nil,
:task_time=>nil,
:processing_total_sum=>nil,
:subject=>nil,
:outbound_campaign_name=>nil,
:outbound_campaign_id=>nil,
:additional_info=>nil,
:destination=>nil}
    ]

    savon.expects(:get_contacts).with(message: message).returns(fixture)

    params = { agent_id: 2000049,
               start_date: '2016-06-14', 
               end_date: '2016-06-15',
               contact_type: 'PBX',
               team_name: 'Helpdesk',
               service_group_id: 4,
               service_id: 137
             }
    response = BackendService.new.get_agent_contacts(params)

    expect(response).to eq(expected)
  end

  it "Should return empty array if there is only header data" do
    fixture = File.read("spec/fixtures/backend_service/get_agent_contacts_2.xml")

    message = { serviceGroupID: 4, serviceID: 137, teamID: "Helpdesk",
    agentID: 2000049, startDate: "2016-06-14", endDate: "2016-06-15",
    contactTypes: 'PBX', useServiceTime: false }

    expected = []

    savon.expects(:get_contacts).with(message: message).returns(fixture)

    params = { agent_id: 2000049,
               start_date: '2016-06-14', 
               end_date: '2016-06-15',
               contact_type: 'PBX',
               team_name: 'Helpdesk',
               service_group_id: 4,
               service_id: 137
             }

    response = BackendService.new.get_agent_contacts(params)

    expect(response).to eq(expected)
  end


it "Should return empty array if there is empty response" do
    fixture = File.read("spec/fixtures/backend_service/get_agent_contacts_3.xml")

    message = { serviceGroupID: 4, serviceID: 137, teamID: "Helpdesk",
    agentID: 2000049, startDate: "2016-06-14", endDate: "2016-06-15",
    contactTypes: 'PBX', useServiceTime: false }

    expected = []

    params = { agent_id: 2000049,
               start_date: '2016-06-14', 
               end_date: '2016-06-15',
               contact_type: 'PBX',
               team_name: 'Helpdesk',
               service_group_id: 4,
               service_id: 137
             }

    savon.expects(:get_contacts).with(message: message).returns(fixture)

    response = BackendService.new.get_agent_contacts(params)

    expect(response).to eq(expected)
  end

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

  it "get_agents should return 3 agents" do
    fixture = File.read("spec/fixtures/backend_service/get_agents_many.xml")
    savon.expects(:get_agents).returns(fixture)
    response = BackendService.new.get_agents
    expect(response).to eq([
      { agent_id: 123, first_name: 'Uolevi', last_name: 'Kinnunen', team_name: 'Helpdesk' },
      { agent_id: 345, first_name: 'Anton', last_name: 'Ilves', team_name: 'Helpdesk' },
      { agent_id: 567, first_name: 'Urpu', last_name: 'Kukkonen', team_name: 'Helpdesk' }
    ])
  end

  it "get_agents should return 1 agents" do
    fixture = File.read("spec/fixtures/backend_service/get_agents_one.xml")
    savon.expects(:get_agents).returns(fixture)
    response = BackendService.new.get_agents
    expect(response).to eq([
      { agent_id: 123, first_name: 'Marja-Terttu', last_name: 'Isometsä', team_name: 'Helpdesk' },
    ])
  end

  it "get_agents should return 1 agents" do
    fixture = File.read("spec/fixtures/backend_service/get_agents_none.xml")
    savon.expects(:get_agents).returns(fixture)
    response = BackendService.new.get_agents
    expect(response).to be_empty
  end

end
