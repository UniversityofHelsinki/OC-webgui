RSpec.describe DailyContacts, type: :service do

	context "when database contains contacts for the day" do 

		before (:example) do
			time = Time.parse("#{Date.today} 08:00:00 +0000")
		

		#Another day	
		AgentStatus.create(agent_id: 123, team: "Helpdesk", status: "Puhelu", open: false, created_at: time - 1.day + (3.hours + 2.minutes), closed: time - 1.day + (4.hours + 10.minutes))
		AgentStatus.create(agent_id: 225, team: "Helpdesk", status: "Puhelu", open: false, created_at: time - 1.day + (3.hours + 40.minutes), closed: time - 1.day + (3.hours + 58.minutes))
		AgentStatus.create(agent_id: 124, team: "Helpdesk", status: "Chat", open: false, created_at: time - 1.day + (3.hours + 42.minutes), closed: time - 1.day + (3.hours + 48.minutes))

		#8-9
		AgentStatus.create(agent_id: 123, team: "Helpdesk", status: "Chat", open: false, created_at: time + 5.minutes, closed: time + 25.minutes)
		AgentStatus.create(agent_id: 225, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + 25.minutes, closed: time + 35.minutes)
		
		#9-10
		AgentStatus.create(agent_id: 123, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (1.hour + 10.minutes), closed: time + (1.hour + 22.minutes))
		AgentStatus.create(agent_id: 225, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (1.hour + 12.minutes), closed: time + (1.hour + 18.minutes))
		AgentStatus.create(agent_id: 262, team: "Helpdesk", status: "Chat", open: false, created_at: time + (1.hour + 22.minutes), closed: time + (1.hour + 28.minutes))
		AgentStatus.create(agent_id: 124, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (1.hour + 30.minutes), closed: time + (1.hour + 42.minutes))
		AgentStatus.create(agent_id: 123, team: "Helpdesk", status: "Chat", open: false, created_at: time + (1.hour + 44.minutes), closed: time + (1.hour + 58.minutes))

		#10-11
		AgentStatus.create(agent_id: 225, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (2.hours + 2.minutes), closed: time + (2.hours + 22.minutes))
		AgentStatus.create(agent_id: 262, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (2.hours + 10.minutes), closed: time + (2.hours + 58.minutes))

		#11-12
		AgentStatus.create(agent_id: 123, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (3.hours + 2.minutes), closed: time + (4.hours + 10.minutes))
		AgentStatus.create(agent_id: 225, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (3.hours + 40.minutes), closed: time + (3.hours + 58.minutes))
		AgentStatus.create(agent_id: 124, team: "Helpdesk", status: "Chat", open: false, created_at: time + (3.hours + 42.minutes), closed: time + (3.hours + 48.minutes))

		#12-13
		AgentStatus.create(agent_id: 225, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (4.hours + 15.minutes), closed: time + (4.hours + 35.minutes))
		AgentStatus.create(agent_id: 262, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (4.hours + 33.minutes), closed: time + (4.hours + 47.minutes))
		AgentStatus.create(agent_id: 124, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (4.hours + 50.minutes), closed: time + (5.hours + 2.minutes))

		#13-14
		AgentStatus.create(agent_id: 123, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (5.hours + 4.minutes), closed: time + (5.hours + 22.minutes))
		AgentStatus.create(agent_id: 225, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (5.hours + 4.minutes), closed: time + (5.hours + 15.minutes))
		AgentStatus.create(agent_id: 124, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (5.hours + 27.minutes), closed: time + (5.hours + 55.minutes))
		AgentStatus.create(agent_id: 123, team: "Helpdesk", status: "Chat", open: false, created_at: time + (5.hours + 35.minutes), closed: time + (5.hours + 44.minutes))

		#14-15
		AgentStatus.create(agent_id: 262, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (6.hours + 33.minutes), closed: time + (6.hours + 42.minutes))

		#15-16
		AgentStatus.create(agent_id: 124, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (7.hours + 10.minutes), closed: time + (1.hours + 35.minutes))
		AgentStatus.create(agent_id: 262, team: "Helpdesk", status: "Puhelu", open: false, created_at: time + (7.hours + 34.minutes), closed: time + (1.hours + 52.minutes))
		end


		it "returns the correct amount of total contacts for the day and ignores those from other days" do
			expect(DailyContacts.new("Helpdesk").get_contacts_between("00:00:00", "23:59:59")).to eq(22)
		end

		it "returns the correct amount of hours for each specified time period" do
			expect(DailyContacts.new("Helpdesk").get_contacts_between("08:00:00", "08:59:59")).to eq(2)
			expect(DailyContacts.new("Helpdesk").get_contacts_between("09:00:00", "09:59:59")).to eq(5)
			expect(DailyContacts.new("Helpdesk").get_contacts_between("10:00:00", "10:59:59")).to eq(2)
			expect(DailyContacts.new("Helpdesk").get_contacts_between("11:00:00", "11:59:59")).to eq(3)
			expect(DailyContacts.new("Helpdesk").get_contacts_between("12:00:00", "12:59:59")).to eq(3)
			expect(DailyContacts.new("Helpdesk").get_contacts_between("13:00:00", "13:59:59")).to eq(4)
			expect(DailyContacts.new("Helpdesk").get_contacts_between("14:00:00", "14:59:59")).to eq(1)
			expect(DailyContacts.new("Helpdesk").get_contacts_between("15:00:00", "15:59:59")).to eq(2)
		end

	end


end