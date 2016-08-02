RSpec.describe ContactsService, type: :service do
  time = Time.zone.parse("2016-07-18T08:00:00 #{Time.now.strftime("%z")}")

  def build(*args)
    FactoryGirl.create(*args)
  end

  def params(service_id, ticket_id, agent_id, arrived_in_queue, forwarded_to_agent, answered, call_ended, handling_ended)
    { service_id: service_id,
      ticket_id: ticket_id,
      agent_id: agent_id,
      arrived: arrived_in_queue,
      forwarded_to_agent: forwarded_to_agent,
      answered: answered,
      call_ended: call_ended,
      after_call_ended: handling_ended
    }
  end

  after(:all) do
    Contact.delete_all
    Service.delete_all
    Team.delete_all
    Agent.delete_all
  end

  before (:all) do
    @agent = Agent.create(first_name: "a", last_name: "b")
    build(:team_for_services)
    build(:service_1)
    build(:service_2)
    build(:contact, params(1, '1', @agent.id, time, time + 1.minute, time + 2.minutes, time + 5.minutes, time + 7.minutes))
    build(:contact, params(2, '2', nil, time + 20.minutes, time + 25.minutes, time + 26.minutes, time + 33.minutes, time + 35.minutes))
    build(:contact, params(1, '3', nil, time + 2.hours, time + (2.hours + 20.minutes), time + (2.hours + 21.minutes), time + (2.hours + 41.minutes), time + 3.hours))    
    build(:contact, params(2, '4', nil, time + 3.hours, time + (3.hours), time + (3.hours + 1.minute), time + (3.hours + 5.minutes), time + (3.hours + 9.minutes)))
    build(:contact, params(2, '5', @agent.id, time + 3.hours, time + (3.hours + 4.minutes), time + (3.hours + 5.minutes), time + (3.hours + 10.minutes), time + (3.hours + 12.minutes)))
    build(:contact, params(1, '6', @agent.id, time + 4.hours, time + (4.hours + 2.minutes), time + (4.hours + 3.minutes), time + (4.hours + 8.minutes), nil)) # After call not yet done, should count for avg duration but not for after call
    build(:contact, params(1, '7', @agent.id, time + (2.hours + 10.minutes), nil, nil, time + (2.hours + 15.minutes), nil)) # Missed contact
    build(:contact, params(1, '8', nil, time + (3.hours + 10.minutes), nil, nil, time + (3.hours + 18.minutes), nil)) # Missed contact
    build(:contact, params(1, '9', nil, time + 4.hours, nil, nil, nil, nil)) # In Queue at the moment, shouldn't affect any calculations
    build(:contact, params(2, '10', nil, time + 4.hours, time + (4.hours + 2.minutes), nil, nil, nil )) # Forwarded from Queue to agent but not answered yet, should show up in queue statistics
  end
  
  context "When searching for stats by team" do
    before(:all) do
      @contacts_service = ContactsService.new(Team.find_by_name('Helpdesk'), '2016-07-18T00:00:00', '2016-07-18T23:59:59')
    end

    it "Returns correct amount of answered and missed calls" do
      expect(@contacts_service.num_missed_calls).to eq(2)
      expect(@contacts_service.num_answered_calls).to eq(6)
    end

    it "Returns correct average call duration" do
      expect(@contacts_service.average_call_duration).to eq(440)
    end

    it "Returns correct answered percentage" do
      expect(@contacts_service.answered_percentage).to eq(75.0)
    end

    it "Returns correct average missed call duration" do
      expect(@contacts_service.average_missed_call_duration).to eq(390)
    end

    it "Returns correct average after call duration" do
      expect(@contacts_service.average_after_call_duration).to eq(348)
    end

    it "Returns correct number of calls by hour" do
      expect(@contacts_service.calls_by_hour).to eq([0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    end

    it "Returns correct average queue duration" do
      expect(@contacts_service.average_queue_duration).to eq(291)
    end

    it "Returns correct average queue duration by hour" do
      expect(@contacts_service.average_queue_duration_by_hour).to eq([0, 0, 0, 0, 0, 0, 0, 0, 180, 0, 1200, 120, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    end
  end

  context "When searching for stats by agent" do
    before (:all) do
      @contacts_service = ContactsService.new(Agent.find(@agent.id), '2016-07-18T00:00:00', '2016-07-18T23:59:59')
    end

    it "Returns the agent's answered and missed calls" do
      expect(@contacts_service.num_missed_calls).to eq(1)
      expect(@contacts_service.num_answered_calls).to eq(3)
    end

    it "Returns correct average call duration" do
      expect(@contacts_service.average_call_duration).to eq(260)
    end
   
    it "Returns correct average after call duration" do
      expect(@contacts_service.average_after_call_duration).to eq(120)
    end

    it "Returns correct queue durations by times" do
      expect(@contacts_service.queue_durations_by_times).to eq([['2016-07-18 08:00:00.000000000 +0000', 60.0], ['2016-07-18 11:00:00.000000000 +0000', 240.0], ['2016-07-18 12:00:00.000000000 +0000', 120.0]])
    end

    it "Returns correct correlation of average queeu length and missed calls statistics" do
      expect(@contacts_service.correlation_of_average_queue_length_and_missed_calls).to eq([['2016-07-18 00:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 01:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 01:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 02:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 02:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 03:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 03:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 04:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 04:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 05:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 05:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 06:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 06:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 07:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 07:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 08:00:00.000000000 +0000', 1, 0, 60.0], ['2016-07-18 08:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 09:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 09:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 10:00:00.000000000 +0000', 1, 1, 0], ['2016-07-18 10:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 11:00:00.000000000 +0000', 1, 0, 240.0], ['2016-07-18 11:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 12:00:00.000000000 +0000', 1, 0, 120.0], ['2016-07-18 12:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 13:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 13:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 14:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 14:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 15:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 15:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 16:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 16:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 17:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 17:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 18:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 18:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 19:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 19:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 20:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 20:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 21:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 21:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 22:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 22:30:00.000000000 +0000', 0, 0, 0], ['2016-07-18 23:00:00.000000000 +0000', 0, 0, 0], ['2016-07-18 23:30:00.000000000 +0000', 0, 0, 0]])
    end
  end
end
