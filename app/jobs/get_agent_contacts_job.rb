# Gets contacts for a single agent according to specified parameters and stores the results in DB
class GetAgentContactsJob
  def initialize(params)
    @params = params
  end

  def perform
    sleep 0.2
    BackendService.new.get_agent_contacts(@params).each do |data|
      Contact.create(agent_id: @params[:agent_id],
                     ticket_id: data[:ticket_id],
                     arrived_in_queue: data[:call_arrived_to_queue],
                     forwarded_to_agent: data[:call_forwarded_to_agent],
                     answered: data[:call_answered_by_agent],
                     call_ended: data[:call_ended],
                     handling_ended: data[:call_handling_ended],
                     direction: data[:contact_direction],
                     phone_number: data[:contact_phone_num])
    end
  end

  def queue_name
    'contacts'
  end

  def max_run_time
    120.seconds
  end

  def max_attempts
    4
  end
end
