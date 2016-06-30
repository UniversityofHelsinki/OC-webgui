# API for default State filter preferences
class StatesController < ApplicationController
  def index
    @states = State.all
  end
end
