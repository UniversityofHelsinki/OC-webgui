# API for OC Agent status data
class AgentStatusesController < ApplicationController
#  before_action :ensure_user_is_logged_in, only: [:stats]
#  before_action :ensure_user_is_admin, only: [:stats]
  def index
    @agent_statuses = AgentStatus.where(open: true).joins(agent: :team)
    # Check which agents have been to lunch already, and include the information in the API
    lunched = Rails.cache.read 'lunched'
    lunched ||= Set.new
    @agent_statuses.each do |a|
      a.status = normalize_status(a.status)
      a.lunch = lunched.include? a.agent_id
    end
    @agent_statuses
  end

  def stats
    start_date = Time.parse(params[:start_date]).beginning_of_day
    end_date = Time.parse(params[:end_date]).end_of_day
    team = Team.find_by_name(params[:team_name])
    stats = AgentStatusService.new(team.name, start_date, end_date)
    contacts = ContactsService.new(team, start_date, end_date)
    return render json: {
      stats: stats.stats_by_hour,
      dropped: contacts.dropped_calls_by_hour(settings['others']['sla'])
    } if params[:report_type] == 'day'
    return render json: {
      stats: stats.stats_by_day,
      dropped: contacts.dropped_calls_by_day(settings['others']['sla'])
    } if params[:report_type] == 'month'
    render json: { error: 'Invalid report type requested' }, status: 400
  end

  # Some statuses are merged into one or renamed according to client specifications
  def normalize_status(status)
    case status
    when 'Sisäänkirjaus', 'Sisäänkirjautuminen'
      return 'Vapaa'
    when 'Puhelu (Ulos)', 'Puhelu (Sisään)', 'Ulossoitto'
      return 'Puhelu'
    when /^Varattu \((.*)\)$/
      return Regexp.last_match[1]
    else
      return status
    end
  end
end
