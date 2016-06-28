app_path = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'config/environment'
require 'config/boot'

module Clockwork 
	every(5.seconds, 'track_agent_statuses.job') { Delayed::Job.enqueue TrackAgentStatusesJob.new }
end