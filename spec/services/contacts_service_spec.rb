RSpec.describe ContactsService, type: :service do
  context 'when database contains some agent statuses that correspond to a contact' do
    before(:example) do
      time = Time.parse("#{Time.zone.today} 08:00:00")

      # Another day
      AgentStatus.create(agent_id: 123, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time - 1.day + (3.hours + 2.minutes), closed: time - 1.day + (4.hours + 10.minutes))
      AgentStatus.create(agent_id: 225, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time - 1.day + (3.hours + 40.minutes), closed: time - 1.day + (3.hours + 58.minutes))
      AgentStatus.create(agent_id: 124, team: 'Helpdesk', status: 'Chat', open: false, created_at: time - 1.day + (3.hours + 42.minutes), closed: time - 1.day + (3.hours + 48.minutes))
      # 8-9
      AgentStatus.create(agent_id: 123, team: 'Helpdesk', status: 'Chat', open: false, created_at: time + 5.minutes, closed: time + 25.minutes)
      AgentStatus.create(agent_id: 225, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + 25.minutes, closed: time + 35.minutes)
      AgentStatus.create(agent_id: 123, team: 'Helpdesk', status: 'Jälkikirjaus', open: false, created_at: time + (25.minutes + 1.second), closed: time + 44.minutes)
      # 9-10
      AgentStatus.create(agent_id: 123, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (1.hour + 10.minutes), closed: time + (1.hour + 22.minutes))
      AgentStatus.create(agent_id: 225, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (1.hour + 12.minutes), closed: time + (1.hour + 18.minutes))
      AgentStatus.create(agent_id: 262, team: 'Helpdesk', status: 'Chat', open: false, created_at: time + (1.hour + 22.minutes), closed: time + (1.hour + 28.minutes))
      AgentStatus.create(agent_id: 124, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (1.hour + 30.minutes), closed: time + (1.hour + 42.minutes))
      AgentStatus.create(agent_id: 123, team: 'Helpdesk', status: 'Chat', open: false, created_at: time + (1.hour + 44.minutes), closed: time + (2.hours + 3.minutes))
      # 10-11
      AgentStatus.create(agent_id: 225, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (2.hours + 2.minutes), closed: time + (2.hours + 22.minutes))
      AgentStatus.create(agent_id: 262, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (2.hours + 10.minutes), closed: time + (2.hours + 58.minutes))
      AgentStatus.create(agent_id: 262, team: 'Helpdesk', status: 'Jälkikirjaus', open: false, created_at: time + (2.hours + 58.minutes + 25.seconds), closed: time + (3.hours + 5.minutes))
      # 11-12
      AgentStatus.create(agent_id: 123, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (3.hours + 2.minutes), closed: time + (4.hours + 10.minutes))
      AgentStatus.create(agent_id: 225, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (3.hours + 40.minutes), closed: time + (3.hours + 58.minutes))
      AgentStatus.create(agent_id: 225, team: 'Helpdesk', status: 'Jälkikirjaus', open: false, created_at: time + (3.hours + 58.minutes + 1.second), closed: time + (4.hours + 5.minutes))
      AgentStatus.create(agent_id: 124, team: 'Helpdesk', status: 'Chat', open: false, created_at: time + (3.hours + 42.minutes), closed: time + (3.hours + 48.minutes))
      # 12-13
      AgentStatus.create(agent_id: 225, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (4.hours + 15.minutes), closed: time + (4.hours + 35.minutes))
      AgentStatus.create(agent_id: 262, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (4.hours + 33.minutes), closed: time + (4.hours + 47.minutes))
      AgentStatus.create(agent_id: 124, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (4.hours + 50.minutes), closed: time + (5.hours + 2.minutes))
      # 13-14
      AgentStatus.create(agent_id: 123, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (5.hours + 4.minutes), closed: time + (5.hours + 22.minutes))
      AgentStatus.create(agent_id: 225, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (5.hours + 4.minutes), closed: time + (5.hours + 15.minutes))
      AgentStatus.create(agent_id: 124, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (5.hours + 27.minutes), closed: time + (5.hours + 55.minutes))
      AgentStatus.create(agent_id: 123, team: 'Helpdesk', status: 'Chat', open: false, created_at: time + (5.hours + 35.minutes), closed: time + (5.hours + 44.minutes))
      # 14-15
      AgentStatus.create(agent_id: 262, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (6.hours + 33.minutes), closed: time + (6.hours + 42.minutes))
      # 15-16
      AgentStatus.create(agent_id: 124, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (7.hours + 10.minutes), closed: time + (1.hour + 35.minutes))
      AgentStatus.create(agent_id: 262, team: 'Helpdesk', status: 'Puhelu', open: false, created_at: time + (7.hours + 34.minutes), closed: time + (1.hour + 52.minutes))
    end

    it 'creates Contact objects of those objects and returns them correctly' do
      contacts = ContactsService.new.contacts_for_team('Helpdesk', Time.zone.today.beginning_of_day, Time.zone.today.end_of_day)
      expect(contacts.length).to eq(22)
      contacts.each { |c| expect(c.is_a?(Contact)).to be(true) }
    end

    it 'sets the call start and end times according to status creatiion and closing times' do
      contacts = ContactsService.new.contacts_for_team('Helpdesk', Time.parse("08:00:00").in_time_zone, Time.parse("09:00:00").in_time_zone)
      expect(contacts[0].answered).to eq("#{Time.zone.today} #{Time.parse("08:05:00").in_time_zone}")
      expect(contacts[0].call_ended).to eq("#{Time.zone.today} #{Time.parse("08:25:00").in_time_zone}")
      expect(contacts[0].agent_id).to eq(123)

      expect(contacts[1].answered).to eq("#{Time.zone.today} #{Time.parse("08:25:00").in_time_zone}")
      expect(contacts[1].call_ended).to eq("#{Time.zone.today} #{Time.parse("08:35:00").in_time_zone}")
      expect(contacts[1].agent_id).to eq(225)
    end

    it 'correctly accounts for after call status occurring right after the contact' do
      contacts = ContactsService.new.contacts_for_team('Helpdesk', Time.parse("08:00:00").in_time_zone, Time.parse("08:06:00").in_time_zone)
      expect(contacts[0].handling_ended).to eq("#{Time.zone.today} #{Time.parse("08:44:00").in_time_zone}")
    end

    it 'ignores after call status which might be connected to a different contact' do
      contacts = ContactsService.new.contacts_for_team('Helpdesk', Time.parse("10:00:00").in_time_zone, Time.parse("11:06:00").in_time_zone)
      expect(contacts[0].handling_ended).to be(nil)
      expect(contacts[1].handling_ended).to be(nil)
    end
  end
end
