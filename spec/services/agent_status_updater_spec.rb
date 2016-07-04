RSpec.describe AgentStatusUpdater, type: :service do

  def now
    Time.at(Time.zone.now.to_i)
  end

  def build(*args)
    FactoryGirl.build(*args)
  end

	it "works with nil inputs" do
		AgentStatusUpdater.new(now, nil).update_statuses(nil, [])
		AgentStatusUpdater.new(now, nil).update_statuses([], nil)
		AgentStatusUpdater.new(now, nil).update_statuses([], [])
		AgentStatusUpdater.new(now, nil).update_statuses(nil, nil)
	end
  
  context "When an AgentStatus result appears for the first time" do 
    before (:example) do
      new_data = [build(:status1a), build(:status2a)]
      AgentStatusUpdater.new(now, nil).update_statuses(nil, new_data)
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
      old_data = [build(:status1a, time_in_status: "20")]
      new_data = [build(:status1a, time_in_status: "25")]
      AgentStatusUpdater.new(now, nil).update_statuses(nil, old_data)
      AgentStatusUpdater.new(now + 5.seconds, now).update_statuses(old_data, new_data)
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
			old_data = [build(:status1a, time_in_status: "10"), build(:status2a)]
      new_data = [build(:status1a, time_in_status: "20")]
			AgentStatusUpdater.new(now, nil).update_statuses(nil, old_data)
			AgentStatusUpdater.new(now + 10.seconds, now).update_statuses(old_data, new_data)
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
			old_data = [build(:status1a, time_in_status: "10"), build(:status2a, time_in_status: "15")]
      new_data = [build(:status1a, time_in_status: "20"), build(:status2a, time_in_status: "25")]
			AgentStatusUpdater.new(now, nil).update_statuses(nil, old_data)
			AgentStatusUpdater.new(now + 10.seconds, now).update_statuses(old_data, new_data)
			AgentStatusUpdater.new(now + 20.seconds, now + 10.seconds).update_statuses(new_data, [])			
		end

    it "tracks the number of status changes correctly" do
      expect(AgentStatus.all.length).to eq(2)
    end

		it "closes all remaining agent statuses" do
			expect(AgentStatus.where(open: true).length).to eq(0)
		end
	end

	context "if an agent's status has changed to a different one" do
		before (:example) do
			old_data = [build(:status1a, time_in_status: "15"), build(:status2a, time_in_status: "5")]
			new_data = [build(:status1b, time_in_status: "10"), build(:status2b, time_in_status: "7")]
			AgentStatusUpdater.new(now, nil).update_statuses(nil, old_data)
			AgentStatusUpdater.new(now + 10.seconds, now).update_statuses(old_data, new_data)
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
			old_data = [build(:status1a, time_in_status: "22")]
			new_data = [build(:status1a, time_in_status: "15")]
			AgentStatusUpdater.new(now, nil).update_statuses(nil, old_data)
			AgentStatusUpdater.new(now + 15.seconds, now).update_statuses(old_data, new_data)
		end

		it "generates a new open status for the statuses where the time in status decreased" do
			expect(AgentStatus.all.length).to eq(2)
		end

		it "closes the old statuses correctly" do 
      expect(AgentStatus.first.open).to be(false)
      expect(AgentStatus.second.open).to be(true)
		end
	end

	context "if a new agent logs in" do
		before (:example) do 
			old_data = [build(:status1a, time_in_status: "10")]
			new_data = [build(:status2a, time_in_status: "3"), build(:status1a, time_in_status: "15")]
			AgentStatusUpdater.new(now, nil).update_statuses(nil, old_data)
			AgentStatusUpdater.new(now + 5.seconds, now).update_statuses(old_data, new_data)
		end

		it "generates a new open status for the new person" do 
			expect(AgentStatus.all.length).to eq(2)
			expect(AgentStatus.where(open: true).length).to eq(2)
		end
	end
end
