require 'pp'
RSpec.describe TrackAgentStatusesJob, type: :job do
  it "makes sure Rails cache is empty first and is then populated with agents who have had lunch" do 
    data = FactoryGirl.build(:get_agent_online_state_1)
    allow_any_instance_of(BackendService).to receive(:get_agent_online_state).and_return(data)

    cache1 = Rails.cache.fetch('lunched', force: true)
    expect(cache1).to be(nil)

    TrackAgentStatusesJob.new.perform

    cache2 = Rails.cache.fetch('lunched', force: true)
    expected2 = Set.new [31]
    expect(cache2).to eq(expected2)
  end

  it "should save the lunch after agent has returned from lunch and changed its online state and cache should contain 2 agents after another one has had lunch" do
    data = FactoryGirl.build(:get_agent_online_state_2)
    allow_any_instance_of(BackendService).to receive(:get_agent_online_state).and_return(data)

    cache3 = Rails.cache.fetch('lunched', force: true)
    expected3 = Set.new [31]
    expect(cache3).to eq(expected3)

    TrackAgentStatusesJob.new.perform

    cache4 = Rails.cache.fetch('lunched', force: true)
    expected4 = Set.new [31, 44]
    expect(cache4).to eq(expected4)
  end
end
