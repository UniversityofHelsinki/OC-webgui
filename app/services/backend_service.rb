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
    #test
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
        #Some states are randomly capitalized and include <> brackets, the brackets are trimmed out and each individual word in the state is capitalized. Unicode characters require a workaround using mb_chars.
        status: normalize_status(normalize_unicode_string(attrs[:string][3])),
        time_in_status: attrs[:string][4]
      }
    end
  rescue Savon::HTTPError => error
    puts error.http.code
    #raise
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
    #raise
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
    #raise
    return []
  end

 private 

 def normalize_unicode_string(str)
  str.tr('<->', '').mb_chars.titleize.wrapped_string
 end

 #Some statuses are merged into one or renamed according to client specifications
 def normalize_status(status)
  if status == "Sisäänkirjaus" || status == "Sisäänkirjautuminen"
    return "Vapaa"
  end
  if status == "Puhelu (Ulos)" || status == "Puhelu (Sisään)" || status == "Ulossoitto"
    return "Puhelu"
  end
  if status == "Varattu (Chat)" 
    return "Chat"
  end
  status 
  end
end
