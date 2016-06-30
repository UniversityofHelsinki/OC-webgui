# Provides service for calculating Contact objects out of AgentStatus data that corresponds to answered contacts
class ContactsService
  def initialize
    @contact_statuses = ['Puhelu', 'Puhelu (Ulos)', 'Puhelu (Sisään)', 'Ulossoitto', 'Chat']
  end

  def contacts_for_team(team_name, starttime, endtime)
    statuses = AgentStatus.where(open: false, team: team_name, status: @contact_statuses, created_at: starttime..endtime)
    convert_to_contacts(statuses)
  end

  private

  def convert_to_contacts(statuses)
    statuses.map do |status|
      contact = Contact.new(agent_id: status.agent_id, answered: status.created_at, call_ended: status.closed)
      after_call = after_call_for(contact)
      contact.handling_ended = after_call.closed if after_call
      contact
    end
  end

  # Returns the after call state for the specified contact if one is found with reasonable confidence
  def after_call_for(contact)
    after_call = AgentStatus.find_by('created_at > ? AND agent_id = ?', contact.call_ended, contact.agent_id)
    return nil unless after_call
    if after_call.status == 'Jälkikirjaus' && after_call.created_at.to_i <= (contact.call_ended.to_i + 2) && !after_call.open
      return after_call
    end
    nil
  end
end
