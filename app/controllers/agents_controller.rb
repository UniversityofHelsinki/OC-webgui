class AgentsController < ApplicationController
  def index
    @agents = Agent.all
  end
end
