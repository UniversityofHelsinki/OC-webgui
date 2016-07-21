require 'pp'
# API for OC Agent status data
class AgentStatusesController < ApplicationController
  def index
    @agent_statuses = AgentStatus.where(open: true).joins(agent: :team)
    lunched = Rails.cache.fetch('lunched', force: true)
    @agent_statuses.each { |a|
      a.status = normalize_status(a.status)
      a.lunch = false
      a.lunch = true if lunched.include? a.agent_id
    }
    @agent_statuses
  end

  # Some statuses are merged into one or renamed according to client specifications
  def normalize_status(status)
    case status
    when 'Sisäänkirjaus' || 'Sisäänkirjautuminen'
      return 'Vapaa'
    when 'Puhelu (Ulos)' || status == 'Puhelu (Sisään)' || status == 'Ulossoitto'
      return 'Puhelu'
    when 'Varattu (Chat)'
      return 'Chat'
    else
      return status
    end
  end
end
