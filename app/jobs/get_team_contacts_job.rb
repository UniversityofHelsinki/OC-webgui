# Gets all contacts for every agent in a team for the specified timeframe
class GetTeamContactsJob
  def initialize(team, start_date, end_date)
    @team = team
    @start_date = start_date
    @end_date = end_date
  end

  def perform
    services = Team.find_by(name: @team).services
    services.each do |service|
      Delayed::Job.enqueue GetServiceContactsJob.new(service.id, @start_date, @end_date)
    end
  end

  def queue_name
    'contacts'
  end

  def max_run_time
    120.seconds
  end

  def max_attempts
    1
  end
end
