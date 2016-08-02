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
      'queue_durations_by_times' => [['2016-07-18 05:00:00.000000000 +0000', 60.0], ['2016-07-18 08:00:00.000000000 +0000', 240.0], ['2016-07-18 09:00:00.000000000 +0000', 120.0]],
      'correlation_of_average_queue_length_and_missed_calls' => [['2016-07-18 00:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 01:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 01:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 02:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 02:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 03:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 03:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 04:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 04:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 05:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 05:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 06:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 06:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 07:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 07:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 08:00:00.000000000 +0300', 1, 0, 60.0], ['2016-07-18 08:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 09:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 09:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 10:00:00.000000000 +0300', 1, 1, 0], ['2016-07-18 10:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 11:00:00.000000000 +0300', 1, 0, 240.0], ['2016-07-18 11:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 12:00:00.000000000 +0300', 1, 0, 120.0], ['2016-07-18 12:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 13:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 13:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 14:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 14:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 15:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 15:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 16:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 16:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 17:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 17:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 18:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 18:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 19:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 19:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 20:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 20:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 21:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 21:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 22:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 22:30:00.000000000 +0300', 0, 0, 0], ['2016-07-18 23:00:00.000000000 +0300', 0, 0, 0], ['2016-07-18 23:30:00.000000000 +0300', 0, 0, 0], ['2016-07-19 00:00:00.000000000 +0300', 0, 0, 0], ['2016-07-19 00:30:00.000000000 +0300', 0, 0, 0]]


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
    allow_any_instance_of(ContactsService).to receive(:queue_durations_by_times).and_return(expected['queue_durations_by_times'])
    allow_any_instance_of(ContactsService).to receive(:correlation_of_average_queue_length_and_missed_calls).and_return(expected['correlation_of_average_queue_length_and_missed_calls'])
    get :stats, format: :json
    expect(JSON.parse(response.body)).to eq(expected)
  end
end
