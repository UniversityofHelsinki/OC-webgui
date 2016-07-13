class AgentStatus < ActiveRecord::Base
  attr_accessor :time_in_status
  belongs_to :agent
end
