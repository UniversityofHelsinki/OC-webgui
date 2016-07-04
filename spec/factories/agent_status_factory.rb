FactoryGirl.define do 
  factory :status1a, class: AgentStatus do
    agent_id "123"
    team "Helpdesk"
    status "Vapaa"
    time_in_status "10"
  end

  factory :status1b, class: AgentStatus do
    agent_id "123"
    team "Helpdesk"
    status "Backoffice"
    time_in_status "10"
  end

  factory :status2a, class: AgentStatus do
    agent_id "456"
    team "Helpdesk"
    status "Puhelu"
    time_in_status "10"
  end

  factory :status2b, class: AgentStatus do
    agent_id "456"
    team "Helpdesk"
    status "Jälkikirjaus"
    time_in_status "10"
  end

end
