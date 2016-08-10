# API for default State filter preferences
class StatesController < ApplicationController
  def index
    render json: @states = State.all
  end
end
