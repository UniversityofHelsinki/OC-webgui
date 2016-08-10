# API for Agents data
class AgentsController < ApplicationController
  def index
    render json: @agents = Agent.all
  end
end
