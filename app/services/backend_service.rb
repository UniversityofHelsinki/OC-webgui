require 'savon'
require 'dotenv'

# This class communicates with Elisa Orange Contact SOAP API.
class BackendService
  def initialize
    @client = Savon.client(
      wsdl: 'https://ocsaas.elisa.fi/dsjicsewrxrtblidogief/reportwebservice/reportservice.asmx?wsdl',
      namespaces: { 'xmlns:oc' => 'http://elisa.ccreport.fi/' },
      follow_redirects: true,
      soap_header: {
        'oc:ServiceAuthHeader' => {
          'oc:WebServicePassword' => ENV['ORANGE_CONTACT_PASSWORD']
        }
      }
    )
  end

 # Method for accessing customer contacts that specific agent
 # has had.
  def get_agent_contacts
    message = { serviceGroupID: 4, serviceID: 137, teamID: "Helpdesk",
    agentID: 2000049, startDate: '2016-06-14', endDate: '2016-06-15',
    contactTypes: 'PBX', useServiceTime: true }

    reply = @client.call(:get_contacts, message: message)
    data = reply.body.dig(:get_contacts_response,
			  :get_contacts_result,
			  :array_of_string)

    return [] unless data
    data = [data] unless data_is_a? Array
    data.map do |attrs|
      {
	ticket_id: attrs[:string][0],
	call_arrived_to_queue: 
	queued_seconds: 
	call_forwarded_to_agent: 
	call_answered_by_agent: 
	call_ended: 
	call_handling_ended: 
	call_length: 
	call_handling_total: 
	service_type: 
	contact_direction: 
	contact_type: 
	contact_phone_num: 
	contact_handler: 
	contact_number: 
	contact_state: 
	contact_total_handling: 
	sub_group: )
      }
    end
  end

  def get_agent_online_state
    reply = @client.call(:get_agent_online_state)
    data = reply.body.dig(:get_agent_online_state_response,
                          :get_agent_online_state_result,
                          :array_of_string)
    return [] unless data
    data = [data] unless data.is_a? Array
    data.map do |attrs|
      {
        agent_id: attrs[:string][0],
        full_name: attrs[:string][1],
        team: attrs[:string][2],
        status: attrs[:string][3],
        time_in_status: attrs[:string][4]
      }
    end
  end

  def get_general_queue
    reply = @client.call(:get_general_queue)
    data = reply.body.dig(:get_general_queue_response,
                          :get_general_queue_result,
                          :array_of_string)
    return [] unless data
    data = [data] unless data.is_a? Array

    # TODO: change variable names
    data.map do |attrs|
      {
        line: attrs[:string][0],
        label: attrs[:string][1],
        time_in_queue: attrs[:string][7]
      }
    end
  end

  # def get_teams
  #   reply = @client.call(:get_teams)
  #   data = reply.body.dig(:get_teams_response,
  #                         :get_teams_result,
  #                         :string) # ei array_of_string
  #   return [] unless data
  #   data = [data] unless data.is_a? Array
  #   data.map do |attrs|
  #     {
  #       agent_id: attrs[:string][0],
  #       full_name: attrs[:string][1],
  #       team: attrs[:string][2],
  #       status: attrs[:string][3],
  #       time_in_status: attrs[:string][4]
  #     }
  #   end
  # end
end
