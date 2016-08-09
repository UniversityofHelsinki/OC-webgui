# API for default Team filter preferences
class TeamsController < ApplicationController
  def index
    render json: @teams = Team.all
  end
end
