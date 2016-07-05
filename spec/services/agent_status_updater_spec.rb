RSpec.describe AgentStatusUpdater, type: :service do
  include Now

  def build(*args)
    FactoryGirl.build(*args)
  end

  def updater(*args)
    AgentStatusUpdater.new(*args)
  end

  it "works with nil inputs" do
    updater(now, nil).update_statuses(nil)
    updater(now, nil).update_statuses([])
  end
  
  context "When an AgentStatus result appears for the first time" do 
    before (:example) do
      new_data = [build(:status_1a), build(:status_2a)]
      updater(now, nil).update_statuses(new_data)
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
      updater(now, nil).update_statuses(old_data)
      updater(now + 5.seconds, now).update_statuses(new_data)
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
      updater(now, nil).update_statuses(old_data)
      updater(now + 10.seconds, now).update_statuses(new_data)
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
      updater(now, nil).update_statuses(old_data)
      updater(now + 10.seconds, now).update_statuses(new_data)
      updater(now + 20.seconds, now + 10.seconds).update_statuses(nil)     
    end

    it "tracks the number of status changes correctly" do
      expect(AgentStatus.all.length).to eq(2)
    end

    it "closes all remaining agent statuses" do
      expect(AgentStatus.where(open: true).length).to eq(0)
    end

    it "records the last reliable status for the closed statuses correctly" do
      expect(AgentStatus.first.last_reliable_status).to eq(now + 10.seconds)
      expect(AgentStatus.second.last_reliable_status).to eq(now)      
    end
  end

  context "if an agent logs out while the last successful job run is unknown" do
    before (:example) do 
      data = [build(:status_1a)]
      updater(now, nil).update_statuses(data)
      updater(now + 15.seconds, nil).update_statuses(nil)
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
      updater(now, nil).update_statuses(old_data)
      updater(now + 10.seconds, now).update_statuses(new_data)
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
      old_data = [build(:status_1a, time_in_status: "22"), build(:status_2a, time_in_status: "5")]
      new_data = [build(:status_1a, time_in_status: "15"), build(:status_2a, time_in_status: "20")]
      updater(now, nil).update_statuses(old_data)
      updater(now + 15.seconds, now).update_statuses(new_data)
    end

    it "generates a new open status for the statuses where the time in status decreased" do
      expect(AgentStatus.all.length).to eq(3)
    end

    it "closes the old statuses correctly" do 
      expect(AgentStatus.first.open).to be(false)
      expect(AgentStatus.second.open).to be(true)
    end
  end

  context "if a new agent logs in" do
    before (:example) do 
      old_data = [build(:status_1a, time_in_status: "10")]
      new_data = [build(:status_2a, time_in_status: "3"), build(:status_1a, time_in_status: "15")]
      updater(now, nil).update_statuses(old_data)
      updater(now + 5.seconds, now).update_statuses(new_data)
    end

    it "generates a new open status for the new person" do 
      expect(AgentStatus.all.length).to eq(2)
      expect(AgentStatus.where(open: true).length).to eq(2)
    end
  end

end
