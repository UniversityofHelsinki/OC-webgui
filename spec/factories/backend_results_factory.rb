FactoryGirl.define do 
  factory :get_team_contacts_1, class: Array do

    contact_1 {{ ticket_id: "1",
                 arrived: "2016-06-20 10:00:00",
                 time_in_queue: 40,
                 forwarded_to_agent: "2016-06-20 10:00:40",
                 answered: "2016-06-20 10:00:50",
                 call_ended: "2016-06-20 10:10:00",
                 after_call_ended: "2016-06-20 10:12:00",
                 total_response_time: 1200,
                 total_handle_time: 1150,
                 service_name: "Neuvonta Fin",
                 direction: "I",
                 contact_type: "PBX",
                 contact_information: "0401234567",
                 agent_name: "Neuvolainen Matti",
                 customer_id: "-1",
                 contact_reason: "Onnistunut kontakti",
                 information: nil,
                 ivr_feedback: nil,
                 category_of_recording: nil,
                 recorded: nil,
                 inserted_to_db: "2016-06-20 10:00:50",
                 task_count: 0,
                 task_time: 0,
                 processing_total_sum: 1200,
                 subject: nil,
                 outbound_campaign_name: nil,
                 outbound_campaign_id: nil,
                 additional_info: nil,
                 destination: nil }}

    contact_2 {{ ticket_id: "2",
                 arrived: "2016-06-20 10:00:00",
                 time_in_queue: 120,
                 forwarded_to_agent: "2016-06-20 10:02:00",
                 answered: "2016-06-20 10:02:50",
                 call_ended: "2016-06-20 10:05:00",
                 after_call_ended: "2016-06-20 10:08:00",
                 total_response_time: 480,
                 total_handle_time: 360,
                 service_name: "Neuvonta Eng",
                 direction: "O",
                 contact_type: "PBX",
                 contact_information: "0401212121",
                 agent_name: "Agentikkala Antti",
                 customer_id: "-1",
                 contact_reason: "Onnistunut kontakti",
                 information: nil,
                 ivr_feedback: nil,
                 category_of_recording: nil,
                 recorded: nil,
                 inserted_to_db: "2016-06-20 10:00:00",
                 task_count: 0,
                 task_time: 0,
                 processing_total_sum: 480,
                 subject: nil,
                 outbound_campaign_name: nil,
                 outbound_campaign_id: nil,
                 additional_info: nil,
                 destination: nil }}

      initialize_with { [contact_1, contact_2] } 
  end

  factory :get_agent_online_state_1, class: Array do
    contact_1 {{
      agent_id: 31,
      name: "Testaaja",
      team: "Helpdesk",
      status: "Ruokatunti",
      time_in_status: 111
    }}

    contact_2 {{
      agent_id: 44,
      name: "Testaaja 2",
      team: "Helpdesk",
      status: "Vapaa",
      time_in_status: 876
    }}

    initialize_with { [contact_1, contact_2] } 
  end

  factory :get_agent_online_state_2, class: Array do
    contact_1 {{
      agent_id: 31,
      name: "Testaaja",
      team: "Helpdesk",
      status: "Backoffice",
      time_in_status: 11
    }}

    contact_2 {{
      agent_id: 44,
      name: "Testaaja 2",
      team: "Helpdesk",
      status: "Ruokatunti",
      time_in_status: 21
    }}

    initialize_with { [contact_1, contact_2] } 
  end
end

=begin
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
=end
