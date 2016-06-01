class QueueController < ApplicationController
  # GET /queue
  # GET /queue.json
  def index
    @queue = BackendService.new.get_general_queue.map do |data|
      Queue.create(first: data[:first]) # dunno variable name yet
    end
  end
end
