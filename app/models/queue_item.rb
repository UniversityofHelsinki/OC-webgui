class QueueItem < ActiveRecord::Base
  belongs_to :service
  has_one :team, through: :service

  attr_accessor :time_in_queue, :service_name
end
