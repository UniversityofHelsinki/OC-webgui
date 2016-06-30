RSpec.describe QueueUpdater, type: :service do

	def init_data
		[
      QueueItem.new(:line=>"131", :label=>"Neuvonta Eng", :time_in_queue=>"372"),
      QueueItem.new(:line=>"161", :label=>"Hakijapalvelut Fin", :time_in_queue=>"58")
		]
	end

	it "works with nil inputs" do
		QueueUpdater.new.update_queue(nil, [])
		QueueUpdater.new.update_queue([], nil)
		QueueUpdater.new.update_queue([], [])
		QueueUpdater.new.update_queue(nil, nil)
	end
	it "creates new statuses if none exist before" do
		new_data = init_data
    puts "JuuuUu"
    puts QueueItem.all
		expect(QueueItem.all.length).to eq(0)
		QueueUpdater.new.update_queue(nil, new_data)
		expect(QueueItem.all.length).to eq(2)
	end
=begin
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
=end
end
