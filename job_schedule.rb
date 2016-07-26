app_path = File.expand_path(File.join(File.dirname(__FILE__), ''))
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'backburner'
require 'app/modules/now.rb'
require 'config/initializers/backburner.rb'
require 'active_support'
require 'active_support/core_ext/time'
Dir[File.dirname(__FILE__) + '/app/jobs/*.rb'].each { |file| require file }

def xsd_time(time)
  time.strftime '%Y-%m-%dT%H:%M:%S%:z'
end

# Determines the schedule for running any recurring background jobs
module Clockwork
  every(5.seconds, 'track_agent_statuses.job') { Backburner.enqueue TrackAgentStatusesJob }
  every(1.second, 'track_queue_items.job') { Backburner.enqueue TrackQueueItemsJob }
  every(1.day, 'clear_rails_cache.job', at: '00:00', tz: 'UTC') { BackBurner.enqueue CacheDeleteJob, 'lunched' }
  every(30.seconds, 'get_helpdesk_contacts.job') do
    Backburner.enqueue GetTeamContactsJob,
                       'Helpdesk',
                       xsd_time(Time.now.beginning_of_day),
                       xsd_time(Time.now.end_of_day)
  end
end
