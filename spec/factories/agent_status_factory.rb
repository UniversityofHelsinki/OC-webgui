FactoryGirl.define do 
  factory :status_1a, class: AgentStatus do
    agent_id "123"
    team "Helpdesk"
    status "Vapaa"
    time_in_status "10"
  end

  factory :status_1b, class: AgentStatus do
    agent_id "123"
    team "Helpdesk"
    status "Backoffice"
    time_in_status "10"
  end

  factory :status_2a, class: AgentStatus do
    agent_id "456"
    team "Helpdesk"
    status "Puhelu"
    time_in_status "10"
  end

  factory :status_2b, class: AgentStatus do
    agent_id "456"
    team "Helpdesk"
    status "Jälkikirjaus"
    time_in_status "10"
  end

end
