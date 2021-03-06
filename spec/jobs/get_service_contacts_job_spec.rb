RSpec.describe GetServiceContactsJob, type: :job do

  it "Parses contact results from BackendService correctly, creates Contact objects and sets their attributes correctly" do 
    Team.create(id: 1, name: "Helpdesk")
    Agent.create(id: 1, first_name: "Matti", last_name: "Neuvolainen", team_id: 1)
    Service.create(id: 1, name: "Neuvonta Fin", team_id: 1)
    data = FactoryGirl.build(:get_service_contacts_1)    
    allow_any_instance_of(BackendService).to receive(:get_service_contacts).and_return(data)
    GetServiceContactsJob.perform(1, '2016-06-01', '2016-06-10')

    contacts = Contact.all
    expect(contacts.size).to eq(1)

    expect(contacts[0].agent_id).to eq(1)
    expect(contacts[0].service_id).to eq(1)
    expect(contacts[0].contact_type).not_to be(nil)
    expect(contacts[0].ticket_id).not_to be(nil)
    expect(contacts[0].forwarded_to_agent).not_to be(nil)
    expect(contacts[0].answered).not_to be(nil)
    expect(contacts[0].call_ended).not_to be(nil)
    expect(contacts[0].after_call_ended).not_to be(nil)
    expect(contacts[0].direction).not_to be(nil)

    expect(contacts[0].contact_type).to eq(data[0][:contact_type])
    expect(contacts[0].ticket_id).to eq(data[0][:ticket_id])
    expect(contacts[0].forwarded_to_agent).to eq(data[0][:forwarded_to_agent])
    expect(contacts[0].answered).to eq(data[0][:answered])
    expect(contacts[0].call_ended).to eq(data[0][:call_ended])
    expect(contacts[0].after_call_ended).to eq(data[0][:after_call_ended])
    expect(contacts[0].direction).to eq(data[0][:direction])

    Agent.create(id: 2, first_name: "Antti", last_name: "Agentikkala", team_id: 1)
    Service.create(id: 2, name: "Neuvonta Eng", team_id: 1)
    data = FactoryGirl.build(:get_service_contacts_2)
    allow_any_instance_of(BackendService).to receive(:get_service_contacts).and_return(data)
    GetServiceContactsJob.perform(2, '2016-06-01', '2016-06-10')

    contacts = Contact.all
    expect(contacts.size).to eq(2)
    
    expect(contacts[1].agent_id).to eq(2)
    expect(contacts[1].service_id).to eq(2)
    expect(contacts[1].contact_type).not_to be(nil)
    expect(contacts[1].ticket_id).not_to be(nil)
    expect(contacts[1].forwarded_to_agent).not_to be(nil)
    expect(contacts[1].answered).not_to be(nil)
    expect(contacts[1].call_ended).not_to be(nil)
    expect(contacts[1].after_call_ended).not_to be(nil)
    expect(contacts[1].direction).not_to be(nil)

    expect(contacts[1].contact_type).to eq(data[0][:contact_type])
    expect(contacts[1].ticket_id).to eq(data[0][:ticket_id])
    expect(contacts[1].forwarded_to_agent).to eq(data[0][:forwarded_to_agent])
    expect(contacts[1].answered).to eq(data[0][:answered])
    expect(contacts[1].call_ended).to eq(data[0][:call_ended])
    expect(contacts[1].after_call_ended).to eq(data[0][:after_call_ended])
    expect(contacts[1].direction).to eq(data[0][:direction])
  end

  it "Ignores contacts from unknown agents" do
    Team.create(id: 1, name: 'Helpdesk')
    Service.create(id: 1, name: 'Neuvonta Fin', team_id: 1)
    data = FactoryGirl.build(:get_service_contacts_1)
    allow_any_instance_of(BackendService).to receive(:get_service_contacts).and_return(data)
    GetServiceContactsJob.perform(1, '2016-06-01', '2016-06-10')
    expect(Contact.all.size).to eq(0)
  end

  it "Correctly stores contacts which were not assigned to any agent(missed contacts)" do
    Team.create(id: 1, name: "Helpdesk")
    Service.create(id: 1, name: 'Neuvonta Eng', team_id: 1)
    data = FactoryGirl.build(:get_service_contacts_3)
    allow_any_instance_of(BackendService).to receive(:get_service_contacts).and_return(data)
    GetServiceContactsJob.perform(1, '2016-06-01', '2016-06-10')

    contacts = Contact.all
    expect(contacts.size).to eq(1)

    expect(contacts[0].agent_id).to be(nil)
    expect(contacts[0].service_id).to eq(1)
    expect(contacts[0].contact_type).not_to be(nil)
    expect(contacts[0].ticket_id).not_to be(nil)
    expect(contacts[0].call_ended).not_to be(nil)
    expect(contacts[0].direction).not_to be(nil)

    expect(contacts[0].contact_type).to eq(data[0][:contact_type])
    expect(contacts[0].ticket_id).to eq(data[0][:ticket_id])
    expect(contacts[0].forwarded_to_agent).to eq(data[0][:forwarded_to_agent])
    expect(contacts[0].answered).to eq(data[0][:answered])
    expect(contacts[0].call_ended).to eq(data[0][:call_ended])
    expect(contacts[0].after_call_ended).to eq(data[0][:after_call_ended])
    expect(contacts[0].direction).to eq(data[0][:direction])
  end
end
