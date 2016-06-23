class Agent < ActiveRecord::Base
	attr_accessor :agent_id, :name, :team, :status, :time_in_status
end