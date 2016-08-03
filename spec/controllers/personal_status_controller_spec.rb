RSpec.describe PersonalStatusController, type: :controller do
  after(:all) do
    User.delete_all
    Agent.delete_all
  end

  context 'when session contains an user with a corresponding agent' do 
    before(:all) do
      agent = Agent.create(first_name: "a", last_name: "b")
      @user = User.create(id: 1, password: "a", agent_id: agent.id)      
    end

    it 'should return personal stats from ContactsService' do
    expected = {
      'answered_calls' => 3,
      'average_call_duration' => 123,
      'average_after_call_duration' => 321
    }

    allow_any_instance_of(ContactsService).to receive(:num_answered_calls).and_return(expected['answered_calls'])
    allow_any_instance_of(ContactsService).to receive(:average_call_duration).and_return(expected['average_call_duration'])
    allow_any_instance_of(ContactsService).to receive(:average_after_call_duration).and_return(expected['average_after_call_duration'])
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    get :index, format: :json
    expect(JSON.parse(response.body)).to eq(expected)
    end
  end

  it "returns 403 when user is not logged in" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
    get :index, format: :json
    expect(response.status).to eq(403)
  end

  it "returns 400 when current user does not match any registered agent" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.new(agent_id: 1))
    get :index, format: :json
    expect(response.status).to eq(400)
  end
end
