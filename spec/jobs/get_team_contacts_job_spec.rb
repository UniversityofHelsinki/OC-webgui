RSpec.describe GetTeamContactsJob, type: :job do 
  it "Adds a new GetServiceContactsJob to Delayed Job Queue for each service associated with the team" do
    Team.create(id: 1, name: 'Helpdesk')
    Service.create(id: 1, name: "Neuvonta Fin", team_id: 1)
    Service.create(id: 2, name: "Neuvonta Eng", team_id: 1)
    backburner = class_double("Backburner").as_stubbed_const
    expect(backburner).to receive(:enqueue).with(GetServiceContactsJob, 1, '2016-06-01', '2016-06-10')
    expect(backburner).to receive(:enqueue).with(GetServiceContactsJob, 2, '2016-06-01', '2016-06-10')
    GetTeamContactsJob.perform('Helpdesk', '2016-06-01', '2016-06-10')
  end
end
