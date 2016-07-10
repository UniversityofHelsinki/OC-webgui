# API for OC Agent status data
class AgentStatusesController < ApplicationController
  def index
    @agent_statuses = AgentStatus.where(open: true)
    @agent_statuses.each { |a| a.status = normalize_status(a.status) }
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
