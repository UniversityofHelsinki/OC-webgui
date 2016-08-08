RSpec.describe AgentStatusUpdater, type: :service do
  test_time = Time.parse('2016-07-11T16:33:52.000Z')

  def build(*args)
    FactoryGirl.build(*args)
  end

  def updater(*args)
    AgentStatusUpdater.new(*args)
  end

  it "works with nil inputs" do
    updater(test_time, nil).update_statuses(nil)
    updater(test_time, nil).update_statuses([])
  end
  
  context "When an AgentStatus result appears for the first time" do 
    before (:example) do
      new_data = [build(:status_1a), build(:status_2a)]
      updater(test_time, nil).update_statuses(new_data)
    end

    it "creates new statuses for each new agent" do
      expect(AgentStatus.all.length).to eq(2)
    end

    it "correctly sets new statuses as open" do
      AgentStatus.all.each { |status| expect(status.open).to be(true)}
    end
  end

  context "with an agent's status staying the same over two updates" do 
    before(:example) do
      old_data = [build(:status_1a, time_in_status: "20")]
      new_data = [build(:status_1a, time_in_status: "25")]
      updater(test_time, nil).update_statuses(old_data)
      updater(test_time + 5.seconds, test_time).update_statuses(new_data)
    end    
    
    it "recognizes the status as being the same" do
      expect(AgentStatus.all.length).to eq(1)
    end

    it "keeps the existing database status as open" do 
      AgentStatus.all.each { |status| expect(status.open).to be(true)}
    end
  end

  context "if an agent has logged out" do 
    before (:example) do
      old_data = [build(:status_1a, time_in_status: "10"), build(:status_2a)]
      new_data = [build(:status_1a, time_in_status: "20")]
      updater(test_time, nil).update_statuses(old_data)
      updater(test_time + 10.seconds, test_time).update_statuses(new_data)
    end

    it "doesn't generate extra statuses in database" do
      expect(AgentStatus.all.length).to eq(2) 
    end

    it "closes the missing agent's status" do
      expect(AgentStatus.second.open).to be(false)
    end
  end

  context "if all agents have logged out" do 
    before (:example) do 
      old_data = [build(:status_1a, time_in_status: "10"), build(:status_2a, time_in_status: "15")]
      new_data = [build(:status_1a, time_in_status: "20")]
      updater(test_time, nil).update_statuses(old_data)
      updater(test_time + 10.seconds, test_time).update_statuses(new_data)
      updater(test_time + 20.seconds, test_time + 10.seconds).update_statuses(nil)     
    end

    it "tracks the number of status changes correctly" do
      expect(AgentStatus.all.length).to eq(2)
    end

    it "closes all remaining agent statuses" do
      expect(AgentStatus.where(open: true).length).to eq(0)
    end

    it "records the last reliable status for the closed statuses correctly" do
      expect(AgentStatus.first.last_reliable_status).to eq(test_time + 10.seconds)
      expect(AgentStatus.second.last_reliable_status).to eq(test_time)      
    end
  end

  context "if an agent logs out while the last successful job run is unknown" do
    before (:example) do 
      data = [build(:status_1a)]
      updater(test_time, nil).update_statuses(data)
      updater(test_time + 15.seconds, nil).update_statuses(nil)
    end

    it "closes the agent's status but doesn't record a successful last state for it" do
      expect(AgentStatus.all.length).to eq(1)
      expect(AgentStatus.first.open).to be(false)
      expect(AgentStatus.first.last_reliable_status).to be(nil)
    end
  end

  context "if an agent's status has changed to a different one" do
    before (:example) do
      old_data = [build(:status_1a, time_in_status: "15"), build(:status_2a, time_in_status: "5")]
      new_data = [build(:status_1b, time_in_status: "10"), build(:status_2b, time_in_status: "7")]
      updater(test_time, nil).update_statuses(old_data)
      updater(test_time + 10.seconds, test_time).update_statuses(new_data)
    end

    it "generates a new status object for each changed status" do 
      expect(AgentStatus.all.length).to eq(4)
    end

    it "closes the previous statuses for agents who changed to a different status" do
      expect(AgentStatus.where(open: true).length).to eq(2)
    end
  end

  context "if an agent's status has the same name but the time has decreased" do
    before (:example) do 
      oldest_data = [build(:status_1a, time_in_status: "5")]
      old_data = [build(:status_1a, time_in_status: "22"), build(:status_2a, time_in_status: "5")]
      new_data = [build(:status_1a, time_in_status: "15"), build(:status_2a, time_in_status: "20")]
      updater(test_time - 17.seconds, nil).update_statuses(oldest_data)
      updater(test_time, test_time - 17.seconds).update_statuses(old_data)
      updater(test_time + 15.seconds, test_time).update_statuses(new_data)
    end

    it "generates a new open status for the statuses where the time in status decreased" do
      expect(AgentStatus.all.length).to eq(3)      
      expect(AgentStatus.first.open).to be(false)
      expect(AgentStatus.second.open).to be(true)
    end
  end

  context "if a new agent logs in" do
    before (:example) do 
      old_data = [build(:status_1a, time_in_status: "10")]
      new_data = [build(:status_2a, time_in_status: "3"), build(:status_1a, time_in_status: "15")]
      updater(test_time, nil).update_statuses(old_data)
      updater(test_time + 5.seconds, test_time).update_statuses(new_data)
    end

    it "generates a new open status for the new person" do 
      expect(AgentStatus.all.length).to eq(2)
      expect(AgentStatus.where(open: true).length).to eq(2)
    end
  end

  context "When SOAP data does not arrive in the expected time" do
    before (:example) do
      @data1=[build(:status_1a, time_in_status: "300"), build(:status_2a, time_in_status: "3")]
      @data1copy=[build(:status_1a, time_in_status: "300"), build(:status_2a, time_in_status: "3")]
      @data2=[build(:status_1a, time_in_status: "305"), build(:status_2a, time_in_status: "8"), build(:status_3a, time_in_status: "3")]
    end

    it "handles a situation where SOAP data comes slightly later than expected"  do
      time = test_time
      updater(time, time - 5.seconds).update_statuses(@data1)
      updater(time + 9.seconds, time).update_statuses(@data2)
      expect(AgentStatus.all.length).to eq(3)
      expect(AgentStatus.where(open: true).length).to eq(3)
    end

    it "handles a situation where SOAP data comes slightly earlier than expected" do 
      time = test_time 
      updater(time, time - 5.seconds).update_statuses(@data1)
      updater(time + 1.second, time).update_statuses(@data2)
      expect(AgentStatus.all.length).to eq(3)
      expect(AgentStatus.where(open: true).length).to eq(3)
    end

    it "handles a situation where the same SOAP response is delivered shortly after the first one" do
      time = test_time
      updater(time, time - 5.seconds).update_statuses(@data1)
      updater(time + 2.seconds, time).update_statuses(@data1)
      expect(AgentStatus.all.length).to eq(2) 
      expect(AgentStatus.where(open: true).length).to eq(2)
    end

    it "handles a situation where the same SOAP response is delivered fairly late after the first time" do
      time = test_time
      updater(time, time - 5.seconds).update_statuses(@data1)
      updater(time + 9.seconds, time).update_statuses(@data1copy)
      expect(AgentStatus.all.length).to eq(2)
    end

    it "handles a situation where the same SOAP response is delivered shortly after first one, then a new response appears" do
      time = test_time
      updater(time, time - 5.seconds).update_statuses(@data1)
      updater(time + 2.seconds, time).update_statuses(@data1copy)
      updater(time + 7.seconds, time + 2.seconds).update_statuses(@data2)
      expect(AgentStatus.all.length).to eq(3) 
      expect(AgentStatus.where(open: true).length).to eq(3)
    end

    it "handles a situation where the same SOAP response is delivered fairly late, then a new response appears" do 
      time = test_time
      updater(time, time - 5.seconds).update_statuses(@data1)
      updater(time + 9.seconds, time).update_statuses(@data1copy)
      updater(time + 10.seconds, time).update_statuses(@data2)
      expect(AgentStatus.all.length).to eq(3) 
      expect(AgentStatus.where(open: true).length).to eq(3)
    end

    it "handles a situation where the same response is delivered several times over a few seconds, then a new one appears" do
      time = test_time
      updater(time, time - 5.seconds).update_statuses(@data1)
      updater(time + 1.second, time).update_statuses(@data1)
      updater(time + 2.seconds, time + 1.second).update_statuses(@data1)
      updater(time + 3.seconds, time + 2.seconds).update_statuses(@data2)
      updater(time + 4.seconds, time + 3.seconds).update_statuses(@data2)
      updater(time + 5.seconds, time + 4.seconds).update_statuses(@data2)

      expect(AgentStatus.all.length).to eq(3) 
      expect(AgentStatus.where(open: true).length).to eq(3)      
    end
  end

  context "when the SOAP delay gets to be very long" do 
    before(:example) do 
      data1=[build(:status_1a, time_in_status: "300"), build(:status_2a, time_in_status: "3")]
      data2=[build(:status_1a, time_in_status: "305"), build(:status_2a, time_in_status: "8"), build(:status_3a, time_in_status: "3")]
      data3=[build(:status_1a, time_in_status: "50"), build(:status_2a, time_in_status: "100")]
      updater(test_time, test_time - 5.seconds).update_statuses(data1)
      updater(test_time + 9.seconds, test_time).update_statuses(data2)
      updater(test_time + 92.seconds, test_time + 9.seconds).update_statuses(data3)
    end

    it "doesn't confuse old and new data" do
      expect(AgentStatus.all.length).to eq(4)
      expect(AgentStatus.where(open: true).length).to eq(2)      
    end
  end  
end
