require 'savon'

class BackendService 

	def get_agent_online_state
		client = Savon.client(
		  wsdl: "https://ocsaas.elisa.fi/dsjicsewrxrtblidogief/reportwebservice/reportservice.asmx?wsdl",
		  namespaces: {"xmlns:oc" => "http://elisa.ccreport.fi/"},
		  follow_redirects: true,
		  soap_header: {
		    "oc:ServiceAuthHeader" => {
		      "oc:WebServicePassword" => "password_here"
		    }
		  }
		)
		reply = client.call(:get_agent_online_state)
		reply.body[:get_agent_online_state_response][:get_agent_online_state_result][:array_of_string]
	end

end