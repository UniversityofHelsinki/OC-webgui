# API for Agents data
class AgentsController < ApplicationController
  def index
    fetch_and_save_all_agents
    @agents = Agent.all
  end

  # Fetches all agents from SOAP and saves them to database
  def fetch_and_save_all_agents
    BackendService.new.get_agents.map do |data|
      name = [data[:last_name], data[:first_name]].join(' ')
      Agent.find_or_create(data[:agent_id], name, data[:team_name])
    end
  end
end
