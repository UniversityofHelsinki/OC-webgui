# API for Agents data
class AgentsController < ApplicationController
  def index
    get_all
    @agents = Agent.all
  end

  def get_all
    BackendService.new.get_agents.map do |data|
      name = [data[:last_name], data[:first_name]].join(' ')
      Agent.find_or_create(data[:agent_id], name, data[:team_name])
    end
  end
end
