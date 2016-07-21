RSpec.describe ContactsService, type: :service do
  context 'when database contains some agent statuses that correspond to a contact' do
    before(:example) do
      time = Time.parse('2016-07-18T08:00:00.000Z')

      Agent.delete_all
      Team.delete_all

      team1 = Team.create(name: 'Helpdesk')
      agent1 = Agent.create(id: 123, team: team1)
      agent2 = Agent.create(id: 225, team: team1)
      agent3 = Agent.create(id: 124, team: team1)
      agent4 = Agent.create(id: 262, team: team1)

      # Another day
      AgentStatus.create(agent: agent1, status: 'Puhelu', open: false, created_at: time - 1.day + (3.hours + 2.minutes), closed: time - 1.day + (4.hours + 10.minutes))
      AgentStatus.create(agent: agent2, status: 'Puhelu', open: false, created_at: time - 1.day + (3.hours + 40.minutes), closed: time - 1.day + (3.hours + 58.minutes))
      AgentStatus.create(agent: agent3, status: 'Chat', open: false, created_at: time - 1.day + (3.hours + 42.minutes), closed: time - 1.day + (3.hours + 48.minutes))
      # 8-9
      AgentStatus.create(agent: agent1, status: 'Chat', open: false, created_at: time + 5.minutes, closed: time + 25.minutes)
      AgentStatus.create(agent: agent2, status: 'Puhelu', open: false, created_at: time + 25.minutes, closed: time + 35.minutes)
      AgentStatus.create(agent: agent1, status: 'Jälkikirjaus', open: false, created_at: time + (25.minutes + 1.second), closed: time + 44.minutes)
      # 9-10
      AgentStatus.create(agent: agent1, status: 'Puhelu', open: false, created_at: time + (1.hour + 10.minutes), closed: time + (1.hour + 22.minutes))
      AgentStatus.create(agent: agent2, status: 'Puhelu', open: false, created_at: time + (1.hour + 12.minutes), closed: time + (1.hour + 18.minutes))
      AgentStatus.create(agent: agent3, status: 'Chat', open: false, created_at: time + (1.hour + 22.minutes), closed: time + (1.hour + 28.minutes))
      AgentStatus.create(agent: agent3, status: 'Puhelu', open: false, created_at: time + (1.hour + 30.minutes), closed: time + (1.hour + 42.minutes))
      AgentStatus.create(agent: agent1, status: 'Chat', open: false, created_at: time + (1.hour + 44.minutes), closed: time + (2.hours + 3.minutes))
      # 10-11
      AgentStatus.create(agent: agent2, status: 'Puhelu', open: false, created_at: time + (2.hours + 2.minutes), closed: time + (2.hours + 22.minutes))
      AgentStatus.create(agent: agent3, status: 'Puhelu', open: false, created_at: time + (2.hours + 10.minutes), closed: time + (2.hours + 58.minutes))
      AgentStatus.create(agent: agent3, status: 'Jälkikirjaus', open: false, created_at: time + (2.hours + 58.minutes + 25.seconds), closed: time + (3.hours + 5.minutes))
      # 11-12
      AgentStatus.create(agent: agent1, status: 'Puhelu', open: false, created_at: time + (3.hours + 2.minutes), closed: time + (4.hours + 10.minutes))
      AgentStatus.create(agent: agent2, status: 'Puhelu', open: false, created_at: time + (3.hours + 40.minutes), closed: time + (3.hours + 58.minutes))
      AgentStatus.create(agent: agent2, status: 'Jälkikirjaus', open: false, created_at: time + (3.hours + 58.minutes + 1.second), closed: time + (4.hours + 5.minutes))
      AgentStatus.create(agent: agent3, status: 'Chat', open: false, created_at: time + (3.hours + 42.minutes), closed: time + (3.hours + 48.minutes))
      # 12-13
      AgentStatus.create(agent: agent2, status: 'Puhelu', open: false, created_at: time + (4.hours + 15.minutes), closed: time + (4.hours + 35.minutes))
      AgentStatus.create(agent: agent3, status: 'Puhelu', open: false, created_at: time + (4.hours + 33.minutes), closed: time + (4.hours + 47.minutes))
      AgentStatus.create(agent: agent3, status: 'Puhelu', open: false, created_at: time + (4.hours + 50.minutes), closed: time + (5.hours + 2.minutes))
      # 13-14
      AgentStatus.create(agent: agent1, status: 'Puhelu', open: false, created_at: time + (5.hours + 4.minutes), closed: time + (5.hours + 22.minutes))
      AgentStatus.create(agent: agent2, status: 'Puhelu', open: false, created_at: time + (5.hours + 4.minutes), closed: time + (5.hours + 15.minutes))
      AgentStatus.create(agent: agent3, status: 'Puhelu', open: false, created_at: time + (5.hours + 27.minutes), closed: time + (5.hours + 55.minutes))
      AgentStatus.create(agent: agent1, status: 'Chat', open: false, created_at: time + (5.hours + 35.minutes), closed: time + (5.hours + 44.minutes))
      # 14-15
      AgentStatus.create(agent: agent3, status: 'Puhelu', open: false, created_at: time + (6.hours + 33.minutes), closed: time + (6.hours + 42.minutes))
      # 15-16
      AgentStatus.create(agent: agent3, status: 'Puhelu', open: false, created_at: time + (7.hours + 10.minutes), closed: time + (7.hour + 35.minutes))
      AgentStatus.create(agent: agent3, status: 'Puhelu', open: false, created_at: time + (7.hours + 34.minutes), closed: time + (7.hours + 52.minutes))
    end
    it 'creates Contact objects of those objects and returns them correctly' do
      contacts = ContactsService.new.contacts_for_team('Helpdesk', Time.parse('2016-07-18T08:00:00.000Z'), Time.parse('2016-07-18T18:00:00.000Z'))
      expect(contacts.length).to eq(22)
      contacts.each { |c| expect(c.is_a?(Contact)).to be(true) }
    end

    it 'sets the call start and end times according to status creation and closing times' do
      contacts = ContactsService.new.contacts_for_team('Helpdesk', Time.parse('2016-07-18T08:00:00.000Z'), Time.parse('2016-07-18T09:00:00.000Z'))
      expect(contacts[0].answered).to eq('2016-07-18T08:05:00.000Z')
      expect(contacts[0].call_ended).to eq('2016-07-18T08:25:00.000Z')
      expect(contacts[0].agent_id).to eq(123)

      expect(contacts[1].answered).to eq(Time.parse('2016-07-18T08:25:00.000Z'))
      expect(contacts[1].call_ended).to eq(Time.parse('2016-07-18T08:35:00.000Z'))
      expect(contacts[1].agent_id).to eq(225)
    end

    it 'correctly accounts for after call status occurring right after the contact' do
      contacts = ContactsService.new.contacts_for_team('Helpdesk', Time.parse('2016-07-18T08:00:00.000Z'), Time.parse('2016-07-18T08:06:00.000Z'))
      expect(contacts[0].handling_ended).to eq(Time.parse('2016-07-18T08:44:00.000Z'))
    end

    it 'ignores after call status which might be connected to a different contact' do
      contacts = ContactsService.new.contacts_for_team('Helpdesk', Time.parse("'2016-07-18T10:00:00.000Z'"), Time.parse("'2016-07-18T11:06:00.000Z'"))
      expect(contacts[0].handling_ended).to be(nil)
      expect(contacts[1].handling_ended).to be(nil)
    end

    context 'no contacts' do
      start_time = Time.parse('2016-07-18T00:00:00.000Z') - 2.days
      end_time = Time.parse('2016-07-18T23:59:59.000Z') - 2.days

      it 'answered calls count is 0' do
        expect(ContactsService.new.answered_calls('Helpdesk', start_time, end_time)).to eq(0)
      end

      it 'average calls duration is 0' do
        expect(ContactsService.new.average_call_duration('Helpdesk', start_time, end_time)).to eq(0)
      end

      it 'average after calls duration is 0' do
        expect(ContactsService.new.average_after_call_duration('Helpdesk', start_time, end_time)).to eq(0)
      end

      it 'should be all zeros' do
        expect(ContactsService.new.calls_by_hour('Helpdesk', start_time, end_time))
          .to eq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
      end
    end

    context 'contact today' do
      start_time = Time.parse('2016-07-18T00:00:00.000Z')
      end_time = Time.parse('2016-07-18T23:59:59.000Z')

      it 'returns answered calls count' do
        expect(ContactsService.new.answered_calls('Helpdesk', start_time, end_time)).to eq(22)
      end

      it 'returns average calls duration' do
        expect(ContactsService.new.average_call_duration('Helpdesk', start_time, end_time)).to eq(1115)
      end

      it 'returns average after calls duration' do
        expect(ContactsService.new.average_after_call_duration('Helpdesk', start_time, end_time)).to eq(651)
      end

      it 'returns calls by hour' do
        expect(ContactsService.new.calls_by_hour('Helpdesk', start_time, end_time))
          .to eq([0, 0, 0, 0, 0, 0, 0, 0, 2, 5, 2, 3, 3, 4, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0])
      end
    end
  end
end
