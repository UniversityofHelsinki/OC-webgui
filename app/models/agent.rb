class Agent < ActiveRecord::Base
  belongs_to :team

  def self.find_or_create(id, full_name, team_name)
    agent = find_or_initialize_by(id: id)
    agent.last_name, agent.first_name = full_name.split(' ')
    agent.team = Team.find_or_create_by(name: team_name)
    agent.save
    agent
  end
end
