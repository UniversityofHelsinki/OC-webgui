RSpec.describe TrackAgentStatusesJob, type: :job do
  it 'stores queue items to cache' do
    a_team = Team.create(name: 'A-Team')
    Service.create(id: 123, language: 'Finnish', team: a_team)
    Service.create(id: 321, language: 'English', team: a_team)

    allow_any_instance_of(BackendService).to receive(:get_general_queue).and_return([
      {
        service_id: 123,
        service_name: 'Finnish Service',
        time_in_queue: 20
      },
      {
        service_id: 321,
        service_name: 'English Service',
        time_in_queue: 11
      }
    ])

    TrackQueueItemsJob.perform

    expect(Rails.cache.read('queue_items')).to eq([
      {
        time_in_queue: 20,
        team: 'A-Team',
        language: 'Finnish'
      },
      {
        time_in_queue: 11,
        team: 'A-Team',
        language: 'English'
      }
    ])
  end
end
