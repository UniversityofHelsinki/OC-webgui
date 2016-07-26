RSpec.describe ContactsController, type: :controller do
  it 'should return data from ContactsService' do
    expected = {
      'answered_calls' => 11,
      'average_call_duration' => 123,
      'average_after_call_duration' => 321,
      'calls_by_hour' => [0, 0, 0, 0, 0, 0, 0, 0, 2, 5, 2, 3, 3, 4, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0],
      'missed_calls' => 2,
      'average_missed_call_duration' => 190,
      'answered_percentage' => 69
    }

    allow_any_instance_of(ContactsService).to receive(:num_answered_calls).and_return(expected['answered_calls'])
    allow_any_instance_of(ContactsService).to receive(:average_call_duration).and_return(expected['average_call_duration'])
    allow_any_instance_of(ContactsService).to receive(:average_after_call_duration).and_return(expected['average_after_call_duration'])
    allow_any_instance_of(ContactsService).to receive(:calls_by_hour).and_return(expected['calls_by_hour'])
    allow_any_instance_of(ContactsService).to receive(:num_missed_calls).and_return(expected['missed_calls'])
    allow_any_instance_of(ContactsService).to receive(:average_missed_call_duration).and_return(expected['average_missed_call_duration'])
    allow_any_instance_of(ContactsService).to receive(:answered_percentage).and_return(expected['answered_percentage'])

    get :stats, format: :json
    expect(JSON.parse(response.body)).to eq(expected)
  end
end
