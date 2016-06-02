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

    # TODO change variable names
    data.map do |attrs|
      {
        line: attrs[:string][0],
        label: attrs[:string][1],
        time_in_queue: attrs[:string][7]
      }
    end
  end
end
