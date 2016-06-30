require 'savon'

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

# Method for getting agent contacts
  def get_agent_contacts(agent_id, start_date, end_date, serviceID)
    message = {
      serviceGroupID: 4,
      serviceID: serviceID,
      teamID: 'Helpdesk',
      agentID: agent_id,
      startDate: start_date,
      endDate: end_date,
      contactTypes: 'PBX',
      useServiceTime: true
    }

    reply = @client.call(:get_contacts, message: message)
    data = reply.body.dig(:get_contacts_response,
                          :get_contacts_result,
                          :array_of_string)

    return [] unless data
    data = [data] unless data.is_a? Array

    data = data.map do |attrs|
      {
        agent_id: agent_id,
        ticket_id: attrs[:string][0],
        call_arrived_to_queue: attrs[:string][1],
        queued_seconds: attrs[:string][2],
        call_forwarded_to_agent: attrs[:string][3],
        call_answered_by_agent: attrs[:string][4],
        call_ended: attrs[:string][5],
        call_handling_ended: attrs[:string][6],
        call_length: attrs[:string][7],
        call_handling_total: attrs[:string][8],
        service_type: attrs[:string][9],
        contact_direction: attrs[:string][10],
        contact_type: attrs[:string][11],
        contact_phone_num: attrs[:string][12],
        contact_handler: attrs[:string][13],
        contact_number: attrs[:string][14],
        contact_state: attrs[:string][15],
        contact_total_handling: attrs[:string][16],
        sub_group: attrs[:string][17]
      }
    end

    # First entry in array always seems to consist of weird numbers, not an actual contact
    data.delete_at(0) if data[0][:contact_type] != 'PBX'
    data
  end

  def get_agents
    reply = @client.call(:get_agents)

    data = reply.body.dig(:get_agents_response,
                          :get_agents_result,
                          :array_of_string)
    return [] unless data
    data = [data] unless data.is_a? Array

    data.map do |attrs|
      {
        agent_id: attrs[:string][0]
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
        name: attrs[:string][1],
        team: attrs[:string][2],
        # Some states are randomly capitalized and include <> brackets, the brackets are trimmed out
        # and each individual word in the state is capitalized.
        # Unicode characters require a workaround using mb_chars.
        status: normalize_status(normalize_unicode_string(attrs[:string][3])),
        time_in_status: attrs[:string][4]
      }
    end
  rescue Savon::HTTPError => error
    puts error.http.code
    return []
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
  rescue Savon::HTTPError => error
    puts error.http.code
    return []
  end

  def get_teams
    reply = @client.call(:get_teams)
    data = reply.body.dig(:get_teams_response,
                          :get_teams_result,
                          :string)
    return [] unless data
    data = [data] unless data.is_a? Array
  rescue Savon::HTTPError => error
    puts error.http.code
    return []
  end

  private

  def normalize_unicode_string(str)
    str.tr('<->', '').mb_chars.titleize.wrapped_string
  end

  # Some statuses are merged into one or renamed according to client specifications
  def normalize_status(status)
    if status == 'Sisäänkirjaus' || status == 'Sisäänkirjautuminen'
      return 'Vapaa'
    end
    if status == 'Puhelu (Ulos)' || status == 'Puhelu (Sisään)' || status == 'Ulossoitto'
      return 'Puhelu'
    end
    return 'Chat' if status == 'Varattu (Chat)'
    status
  end
end
