RSpec.describe ContactsController, type: :controller do
  it 'should return data from ContactsService' do
    expected = {
      'answered_calls' => 11,
      'average_call_duration' => 123,
      'average_after_call_duration' => 321,
      'calls_by_hour' => [0, 0, 0, 0, 0, 0, 0, 0, 2, 5, 2, 3, 3, 4, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0],
      'missed_calls' => 2,
      'average_missed_call_duration' => 190,
      'answered_percentage' => 69,
      'average_queue_duration' => 28,
      'average_queue_duration_by_hour' => [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3],
      'service_level_agreement' => 85
      'queue_durations_by_times' => [['2016-07-18 05:00:00.000000000 +0000', 60.0], ['2016-07-18 08:00:00.000000000 +0000', 240.0], ['2016-07-18 09:00:00.000000000 +0000', 120.0]],
      'missed_calls_by_hour' => [0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7, 11, 11, 11, 11, 11, 11, 11, 11]
    }

    allow_any_instance_of(ContactsService).to receive(:num_answered_calls).and_return(expected['answered_calls'])
    allow_any_instance_of(ContactsService).to receive(:average_call_duration).and_return(expected['average_call_duration'])
    allow_any_instance_of(ContactsService).to receive(:average_after_call_duration).and_return(expected['average_after_call_duration'])
    allow_any_instance_of(ContactsService).to receive(:calls_by_hour).and_return(expected['calls_by_hour'])
    allow_any_instance_of(ContactsService).to receive(:num_missed_calls).and_return(expected['missed_calls'])
    allow_any_instance_of(ContactsService).to receive(:average_missed_call_duration).and_return(expected['average_missed_call_duration'])
    allow_any_instance_of(ContactsService).to receive(:answered_percentage).and_return(expected['answered_percentage'])
    allow_any_instance_of(ContactsService).to receive(:average_queue_duration).and_return(expected['average_queue_duration'])
    allow_any_instance_of(ContactsService).to receive(:average_queue_duration_by_hour).and_return(expected['average_queue_duration_by_hour'])
    allow_any_instance_of(ContactsService).to receive(:service_level_agreement_percentage).and_return(expected['service_level_agreement'])
    allow_any_instance_of(ContactsService).to receive(:queue_durations_by_times).and_return(expected['queue_durations_by_times'])
    allow_any_instance_of(ContactsService).to receive(:missed_calls_by_hour).and_return(expected['missed_calls_by_hour'])
    get :stats, format: :json
    expect(JSON.parse(response.body)).to eq(expected)
  end
end
