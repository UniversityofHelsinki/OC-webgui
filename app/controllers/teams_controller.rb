# API for default Team filter preferences
class TeamsController < ApplicationController
  def index
    @teams = Team.all
  end
end
