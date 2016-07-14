# Gets all contacts for every agent in a team for the specified timeframe
class GetTeamContactsJob
  def initialize(team, start_date, end_date)
    @team = team
    @start_date = start_date
    @end_date = end_date
  end

  def perform
    team = Team.includes(:agents, :services).find_by(name: @team)
    params = {}
    params[:team_name] = @team
    params[:start_date] = @start_date
    params[:end_date] = @end_date
    params[:service_group_id] = team.service_group_id
    contact_types = %w(PBX MANUAL SMS)

    team.agents.each do |agent|
      params[:agent_id] = agent.id

      team.services.each do |service|
        params[:service_id] = service.id

        contact_types.each do |type|
          params[:contact_type] = type
          Delayed::Job.enqueue GetAgentContactsJob.new(params)
        end
      end
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
