class AgentStatus < ActiveRecord::Base
  attr_accessor :time_in_status
  attr_accessor :lunch
  belongs_to :agent
end
