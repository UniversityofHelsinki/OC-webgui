FactoryGirl.define do 
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
