require './config/environment'
require './config/boot'

module Clockwork 
	every(5.seconds, 'track_agent_statuses.job') { Delayed::Job.enqueue TrackAgentStatusesJob.new }
end