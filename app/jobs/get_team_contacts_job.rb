# Gets all contacts for every agent in a team for the specified timeframe. This is achieved through creating sub-queries for each
# service belonging to the team. Team contacts should not be queried directly, as contacts taht are missed or still in the queue
# will not be returned.
class GetTeamContactsJob
  def self.perform(team, start_date, end_date)
    services = Team.find_by(name: team).services
    services.each do |service|
      Backburner.enqueue GetServiceContactsJob, service.id, start_date, end_date
    end
  end

  def self.queue_priority
    10
  end

  def self.queue_respond_timeout
    120
  end
end
