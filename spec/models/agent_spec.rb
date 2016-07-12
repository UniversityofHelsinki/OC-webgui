require 'rails_helper'

RSpec.describe Agent, type: :model do
  describe '.find_or_create' do
    before(:each) do
      Team.delete_all
      Agent.delete_all

      @helpdesk = Team.create(name: 'Helpdesk')
      @a_team = Team.create(name: 'A-Team')
      @terhikki = Agent.create(id: 123, first_name: 'Terhikki', last_name: 'Toivonen', team: @team)
    end

    it 'finds old agent' do
      terhikki = Agent.find_or_create(123, 'Toivonen Terhikki', 'Helpdesk')

      expect(terhikki.id).to eq(123)
      expect(terhikki.first_name).to eq('Terhikki')
      expect(terhikki.last_name).to eq('Toivonen')
      expect(terhikki.team).to eq(@helpdesk)

      expect(Agent.all.length).to eq(1)
      expect(Team.all.length).to eq(2)
    end

    it 'creates new agent' do
      marja_liisa = Agent.find_or_create(321, 'Kivi Marja-Liisa', 'Helpdesk')

      expect(marja_liisa.id).to eq(321)
      expect(marja_liisa.first_name).to eq('Marja-Liisa')
      expect(marja_liisa.last_name).to eq('Kivi')
      expect(marja_liisa.team).to eq(@helpdesk)

      expect(Agent.all.length).to eq(2)
      expect(Team.all.length).to eq(2)
    end

    it 'renames agent' do
      fanni = Agent.find_or_create(123, 'Pukki Fanni', 'Helpdesk')

      expect(fanni.id).to be(123)
      expect(fanni.first_name).to eq('Fanni')
      expect(fanni.last_name).to eq('Pukki')
      expect(fanni.team).to eq(@helpdesk)

      expect(Agent.all.length).to eq(1)
      expect(Team.all.length).to eq(2)
    end

    it 'moves agent to other team' do
      terhikki = Agent.find_or_create(123, 'Toivonen Terhikki', 'A-Team')

      expect(terhikki.id).to eq(123)
      expect(terhikki.first_name).to eq('Terhikki')
      expect(terhikki.last_name).to eq('Toivonen')
      expect(terhikki.team).to eq(@a_team)

      expect(Agent.all.length).to eq(1)
      expect(Team.all.length).to eq(2)
    end

    it 'creates new team for agent' do
      terhikki = Agent.find_or_create(123, 'Toivonen Terhikki', 'Uz')

      expect(terhikki.id).to eq(123)
      expect(terhikki.first_name).to eq('Terhikki')
      expect(terhikki.last_name).to eq('Toivonen')
      expect(terhikki.team.name).to eq('Uz')

      expect(Agent.all.length).to eq(1)
      expect(Team.all.length).to eq(3)
    end
  end
end
