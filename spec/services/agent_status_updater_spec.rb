RSpec.describe AgentStatusUpdater, type: :service do

	def init_data
		[
			AgentStatus.new(:agent_id=>"1000081", :team=>"Helpdesk", :status=>"Backoffice", :time_in_status=>"2565"),
			AgentStatus.new(:agent_id=>"1000021", :team=>"Opiskelijaneuvonta", :status=>"Vapaa", :time_in_status=>"15068"),
			AgentStatus.new(:agent_id=>"1000061", :team=>"Opiskelijaneuvonta", :status=>"Tauko", :time_in_status=>"141"),
			AgentStatus.new(:agent_id=>"1000041", :team=>"Helpdesk", :status=>"Jälkikirjaus", :time_in_status=>"425")
		]
	end

	def data_increased_times
		[
			AgentStatus.new(:agent_id=>"1000081", :team=>"Helpdesk", :status=>"Backoffice", :time_in_status=>"2585"),
			AgentStatus.new(:agent_id=>"1000021", :team=>"Opiskelijaneuvonta", :status=>"Vapaa", :time_in_status=>"15068"),
			AgentStatus.new(:agent_id=>"1000061", :team=>"Opiskelijaneuvonta", :status=>"Tauko", :time_in_status=>"171"),
			AgentStatus.new(:agent_id=>"1000041", :team=>"Helpdesk", :status=>"Jälkikirjaus", :time_in_status=>"445")
		]
	end

	def data_missing_person
		[
			AgentStatus.new(:agent_id=>"1000081", :team=>"Helpdesk", :status=>"Backoffice", :time_in_status=>"2585"),
			AgentStatus.new(:agent_id=>"1000021", :team=>"Opiskelijaneuvonta", :status=>"Vapaa", :time_in_status=>"15068"),
			AgentStatus.new(:agent_id=>"1000041", :team=>"Helpdesk", :status=>"Jälkikirjaus", :time_in_status=>"445")
		]
	end

	def data_different_status
		[
			AgentStatus.new(:agent_id=>"1000081", :team=>"Helpdesk", :status=>"Vapaa", :time_in_status=>"22"),
			AgentStatus.new(:agent_id=>"1000021", :team=>"Opiskelijaneuvonta", :status=>"Jälkikirjaus", :time_in_status=>"33"),
			AgentStatus.new(:agent_id=>"1000061", :team=>"Opiskelijaneuvonta", :status=>"Ruokatunti", :time_in_status=>"55"),
			AgentStatus.new(:agent_id=>"1000041", :team=>"Helpdesk", :status=>"Jälkikirjaus", :time_in_status=>"553")
		]
	end

	def data_decreased_times
		[
			AgentStatus.new(:agent_id=>"1000081", :team=>"Helpdesk", :status=>"Backoffice", :time_in_status=>"2585"),
			AgentStatus.new(:agent_id=>"1000021", :team=>"Opiskelijaneuvonta", :status=>"Vapaa", :time_in_status=>"22"),
			AgentStatus.new(:agent_id=>"1000061", :team=>"Opiskelijaneuvonta", :status=>"Tauko", :time_in_status=>"171"),
			AgentStatus.new(:agent_id=>"1000041", :team=>"Helpdesk", :status=>"Jälkikirjaus", :time_in_status=>"112")
		]
	end

		def data_new_person
		[
			AgentStatus.new(:agent_id=>"1000081", :team=>"Helpdesk", :status=>"Backoffice", :time_in_status=>"2585"),
			AgentStatus.new(:agent_id=>"1000021", :team=>"Opiskelijaneuvonta", :status=>"Vapaa", :time_in_status=>"15068"),
			AgentStatus.new(:agent_id=>"1000061", :team=>"Opiskelijaneuvonta", :status=>"Tauko", :time_in_status=>"171"),
			AgentStatus.new(:agent_id=>"1000041", :team=>"Helpdesk", :status=>"Jälkikirjaus", :time_in_status=>"445"),
			AgentStatus.new(:agent_id=>"1000051", :team=>"Helpdesk", :status=>"Vapaa", :time_in_status=>"12")
		]
	end

	it "works with nil inputs" do
		AgentStatusUpdater.new.update_statuses(nil, [])
		AgentStatusUpdater.new.update_statuses([], nil)
		AgentStatusUpdater.new.update_statuses([], [])
		AgentStatusUpdater.new.update_statuses(nil, nil)
	end

	it "creates new statuses if none exist before" do
		new_data = init_data
		expect(AgentStatus.all.length).to eq(0)
		AgentStatusUpdater.new.update_statuses(nil, new_data)
		expect(AgentStatus.all.length).to eq(4)
	end

	it "correctly sets new statuses as open" do
		new_data = init_data
		AgentStatusUpdater.new.update_statuses(nil, new_data) 
		AgentStatus.all.each { |status| expect(status.open).to be(true)}
	end

	context "if the new statuses have same status as the old ones and time in status has increased or stayed the same" do 

		before(:example) do 
			old_data = init_data
			new_data = data_increased_times
			AgentStatusUpdater.new.update_statuses(nil, old_data)
			AgentStatusUpdater.new.update_statuses(old_data, new_data)
		end

		it "doesn't create new statuses in database" do
			expect(AgentStatus.all.length).to eq(4)
		end

		it "keeps the existing database statuses as open" do 
			AgentStatus.all.each { |status| expect(status.open).to be(true)}
		end
	end

	context "if an agent was in the previous batch of statuses but not in the new one" do 

		before (:example) do
			old_data = init_data
			new_data = data_missing_person
			AgentStatusUpdater.new.update_statuses(nil, old_data)
			AgentStatusUpdater.new.update_statuses(old_data, new_data)
		end

		it "doesn't generate extra statuses in database" do
			expect(AgentStatus.all.length).to eq(4) 
		end

		it "closes the missing agent's status" do
			expect(AgentStatus.where(agent_id: 1000061)[0].open).to be(false)
		end
	end

	context "if no agents appear in the new batch but there were some in the previous one" do 

		before (:example) do 
			old_data = init_data 
			new_data = data_increased_times
			AgentStatusUpdater.new.update_statuses(nil, old_data)
			AgentStatusUpdater.new.update_statuses(old_data, data_increased_times)
			AgentStatusUpdater.new.update_statuses(data_increased_times, [])			
		end

		it "closes all remaining agent statuses" do
			expect(AgentStatus.where(open: true).length).to eq(0)
		end

	end

	context "if an agent's status has changed to a different one" do

		before (:example) do
			old_data = init_data
			new_data = data_different_status
			AgentStatusUpdater.new.update_statuses(nil, old_data)
			AgentStatusUpdater.new.update_statuses(old_data, new_data)
		end

		it "generates a new status object for each changed status" do 
			expect(AgentStatus.all.length).to eq(7)			
			expect(AgentStatus.where(agent_id: 1000081).length).to eq(2)
			expect(AgentStatus.where(agent_id: 1000061).length).to eq(2)
			expect(AgentStatus.where(agent_id: 1000021).length).to eq(2)
		end

		it "closes the previous statuses for agents who changed to a different status" do
			expect(AgentStatus.where(open: true).length).to eq(4)
			expect(AgentStatus.where(agent_id: 1000081, status: "Backoffice")[0].open).to be(false)
			expect(AgentStatus.where(agent_id: 1000021, status: "Vapaa")[0].open).to be(false)
			expect(AgentStatus.where(agent_id: 1000061, status: "Tauko")[0].open).to be(false)			
		end
	end



	context "if an agent's status is the same but the time has decreased" do 

		before (:example) do 
			old_data = init_data 
			new_data = data_decreased_times			
			AgentStatusUpdater.new.update_statuses(nil, old_data)
			AgentStatusUpdater.new.update_statuses(old_data, new_data)
		end

		it "generates a new open status for the statuses where the time in status decreased" do
			expect(AgentStatus.all.length).to eq(6)
			expect(AgentStatus.where(agent_id: 1000021)[1].open).to be(true)
			expect(AgentStatus.where(agent_id: 1000041)[1].open).to be(true)
		end

		it "closes the old statuses correctly" do 
			expect(AgentStatus.where(open: true).length).to eq(4)
			expect(AgentStatus.where(agent_id: 1000021)[0].open).to be(false)
			expect(AgentStatus.where(agent_id: 1000041)[0].open).to be(false)
		end
	end

	context "if a new agent appears who was not in the previous batch" do

		before (:example) do 
			old_data = init_data 
			new_data = data_new_person			
			AgentStatusUpdater.new.update_statuses(nil, old_data)
			AgentStatusUpdater.new.update_statuses(old_data, new_data)
		end

		it "generates a new open status for the new person" do 
			expect(AgentStatus.all.length).to eq(5)
			expect(AgentStatus.where(agent_id: 1000051)[0].open).to be(true)
		end

	end

end