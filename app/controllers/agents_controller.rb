# API for Agents data
class AgentsController < ApplicationController
  def index
    BackendService.new.get_agents.map do |data|
      name = [data[:first_name], data[:last_name]].join(' ')
      Agent.find_or_create(data[:agent_id], name, data[:team])
    end
    @agents = Agent.all
  end
end
