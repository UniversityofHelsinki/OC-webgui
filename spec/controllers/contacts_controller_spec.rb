RSpec.describe ContactsController, type: :controller do
  it 'should return data from ContactsService' do
    expected = {
      'answered_calls' => 11,
      'average_call_duration' => 123,
      'average_after_call_duration' => 321,
      'calls_by_hour' => [0, 0, 0, 0, 0, 0, 0, 0, 2, 5, 2, 3, 3, 4, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    ContactsService.any_instance.stub(:answered_calls).and_return(expected['answered_calls'])
    ContactsService.any_instance.stub(:average_call_duration).and_return(expected['average_call_duration'])
    ContactsService.any_instance.stub(:average_after_call_duration).and_return(expected['average_after_call_duration'])
    ContactsService.any_instance.stub(:calls_by_hour).and_return(expected['calls_by_hour'])

    get :stats, format: :json
    expect(JSON.parse(response.body)).to eq(expected)
  end
end
