class AgentsController < ApplicationController
  before_action :set_agent, only: [:show, :edit, :update, :destroy]

  # GET /agents
  # GET /agents.json
  def index
    @agents = BackendService.new.get_agent_online_state.map do |data|
      Agent.new(agent_id: data[:agent_id],
                name: data[:full_name],
                team: data[:team],
                status: data[:status],
                time_in_status: data[:time_in_status])
    end
  end
end
