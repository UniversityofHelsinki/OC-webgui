class AgentStatusesController < ApplicationController

  # GET /agent_statuses
  # GET /agent_statuses.json
  def index
    @agent_statuses = AgentStatus.where(open: true).sort { |a, b| a.name <=> b.name }
  end
  
end
