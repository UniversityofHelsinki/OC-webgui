RSpec.describe GetTeamContactsJob, type: :job do 
  it "Adds a new GetServiceContactsJob to Delayed Job Queue for each service associated with the team" do
    Team.create(id: 1, name: 'Helpdesk')
    Service.create(id: 1, name: "Neuvonta Fin", team_id: 1)
    Service.create(id: 2, name: "Neuvonta Eng", team_id: 1)
    GetTeamContactsJob.new('Helpdesk', '2016-06-01', '2016-06-10').perform
    jobs = Delayed::Job.all
    expect(jobs.size).to eq(2)
    expect(jobs.first.handler).to include("GetServiceContactsJob")
    expect(jobs.first.handler).to include("service_id: 1")
    expect(jobs.second.handler).to include("GetServiceContactsJob")
    expect(jobs.second.handler).to include("service_id: 2")
  end
end
