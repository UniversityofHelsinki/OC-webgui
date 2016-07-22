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

  def get_team_contacts(team_name, start_date, end_date)
    get_agent_contacts(service_group_id: -1,
                       service_id: -1,
                       team_name: team_name,
                       agent_id: -1,
                       start_date: start_date,
                       end_date: end_date,
                       contact_type: 'PBX EMAIL SMS FAX SCAN CHAT COBRO MANUAL FACE TASK VIDEO')
  end

  # Method for getting agent contacts
  def get_agent_contacts(params)
    message = {
      serviceGroupID: params[:service_group_id],
      serviceID: params[:service_id],
      teamID: params[:team_name],
      agentID: params[:agent_id],
      startDate: params[:start_date],
      endDate: params[:end_date],
      contactTypes: params[:contact_type],
      useServiceTime: true
    }

    reply = @client.call(:get_contacts, message: message)
    data = reply.body.dig(:get_contacts_response,
                          :get_contacts_result,
                          :array_of_string)

    data = check_if_data_exists(data)
    data = map_contacts_data(data)
    delete_contact_headers(data)
    data
  end

  def get_agents
    reply = @client.call(:get_agents)

    data = reply.body.dig(:get_agents_response,
                          :get_agents_result,
                          :array_of_string)
    data = check_if_data_exists(data)

    data.map do |attrs|
      {
        agent_id: Integer(attrs[:string][0], 10),
        last_name: attrs[:string][1],
        first_name: attrs[:string][2],
        team_name: attrs[:string][3]
      }
    end
  end

  def get_services
    reply = @client.call(:get_services)

    data = reply.body.dig(:get_services_response,
                          :get_services_result,
                          :array_of_string)
    data = check_if_data_exists(data)

    data.map do |attrs|
      {
        id: Integer(attrs[:string][0], 10),
        name: attrs[:string][1]
      }
    end
  end

  def get_agent_online_state
    reply = @client.call(:get_agent_online_state)
    data = reply.body.dig(:get_agent_online_state_response,
                          :get_agent_online_state_result,
                          :array_of_string)
    data = check_if_data_exists(data)

    data.map do |attrs|
      {
        agent_id: attrs[:string][0],
        name: attrs[:string][1],
        team: attrs[:string][2],
        # Some states are randomly capitalized and include <> brackets, the brackets are trimmed out
        # and each individual word in the state is capitalized.
        # Unicode characters require a workaround using mb_chars.
        status: normalize_unicode_string(attrs[:string][3]),
        time_in_status: attrs[:string][4]
      }
    end
  rescue Savon::HTTPError => error
    Rails.logger.debug error.http.code
    return []
  end

  def get_general_queue
    reply = @client.call(:get_general_queue)
    data = reply.body.dig(:get_general_queue_response,
                          :get_general_queue_result,
                          :array_of_string)
    data = check_if_data_exists(data)

    data.map do |attrs|
      {
        service_id: attrs[:string][0],
        service_name: attrs[:string][1],
        time_in_queue: attrs[:string][7]
      }
    end
  rescue Savon::HTTPError => error
    Rails.logger.debug error.http.code
    return []
  end

  def get_teams
    reply = @client.call(:get_teams)
    data = reply.body.dig(:get_teams_response,
                          :get_teams_result,
                          :string)
    check_if_data_exists(data)
  rescue Savon::HTTPError => error
    logger.debug error.http.code
    return []
  end

  private

  def normalize_unicode_string(str)
    str.tr('<->', '').mb_chars.titleize.wrapped_string
  end

  def check_if_data_exists(data)
    return [] unless data
    data = [data] unless data.is_a? Array
    data
  end

  def map_contacts_data(data)
    data.map do |attrs|
      {
        ticket_id: attrs[:string][0],
        arrived: attrs[:string][1],
        time_in_queue: attrs[:string][2],
        forwarded_to_agent: attrs[:string][3],
        answered: attrs[:string][4],
        call_ended: attrs[:string][5],
        after_call_ended: attrs[:string][6],
        total_response_time: attrs[:string][7],
        total_handle_time: attrs[:string][8],
        service_name: attrs[:string][9],
        direction: attrs[:string][10],
        contact_type: attrs[:string][11],
        contact_information: attrs[:string][12],
        agent_name: attrs[:string][13],
        customer_id: attrs[:string][14],
        contact_reason: attrs[:string][15],
        information: attrs[:string][16],
        ivr_feedback: attrs[:string][17],
        category_of_recording: attrs[:string][18],
        recorded: attrs[:string][19],
        inserted_to_db: attrs[:string][20],
        task_count: attrs[:string][21],
        task_time: attrs[:string][22],
        processing_total_sum: attrs[:string][23],
        subject: attrs[:string][24],
        outbound_campaign_name: attrs[:string][25],
        outbound_campaign_id: attrs[:string][26],
        additional_info: attrs[:string][27],
        destination: attrs[:string][28]
      }
    end
  end

  def delete_contact_headers(data)
    return if data.empty?
    data.delete_at(0) if data[0][:ticket_id] == '21100'
  end
end
