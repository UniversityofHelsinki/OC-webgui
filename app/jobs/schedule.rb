app_path = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'config/environment'
require 'config/boot'

# Determines the schedule for running any recurring background jobs
module Clockwork
  every(5.seconds, 'track_agent_statuses.job') { Delayed::Job.enqueue TrackAgentStatusesJob.new }
  every(1.second, 'track_queue_items.job') { Delayed::Job.enqueue TrackQueueItemsJob.new }
  every(1.day, 'get_daily_helpdesk_contacts.job', at: '02:00', tz: 'UTC') do
    Delayed::Job.enqueue GetTeamContactsJob.new(team: 'Helpdesk',
                                                start_date: (DateTime.now.utc - 48.hours).strftime,
                                                end_date: DateTime.now.utc.strftime)
  every(1.day, 'clear_rails_cache.job', at: '14:43', tz: 'UTC') { Delayed::Jobs.enqueue ClearRailsCache.new }   
  end
end
