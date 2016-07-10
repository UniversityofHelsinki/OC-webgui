FactoryGirl.define do 

  factory :team_1, class: Team do
    id 1
    name "Helpdesk"
    initialize_with { Team.where(:id => id).first_or_create }
  end

  factory :agent_1, class: Agent do
    id 123
    first_name "etu1"
    last_name "suku1"
    association :team, factory: :team_1
    initialize_with { Agent.where(:id => id).first_or_create }
  end

  factory :agent_2, class: Agent do
    id 456
    first_name "etu2"
    last_name "suku2"
    association :team, factory: :team_1
    initialize_with { Agent.where(:id => id).first_or_create }
  end

  factory :agent_3, class: Agent do
    id 789
    first_name "etu3"
    last_name "suku3"
    association :team, factory: :team_1
    initialize_with { Agent.where(:id => id).first_or_create }
  end

  factory :status_1a, class: AgentStatus do
    status "Vapaa"
    time_in_status "10"
    association :agent, factory: :agent_1
  end

  factory :status_1b, class: AgentStatus do
    status "Backoffice"
    time_in_status "10"
    association :agent, factory: :agent_1
  end

  factory :status_2a, class: AgentStatus do
    status "Puhelu"
    time_in_status "10"
    association :agent, factory: :agent_2
  end

  factory :status_2b, class: AgentStatus do
    status "Jälkikirjaus"
    time_in_status "10"
    association :agent, factory: :agent_2
  end

    factory :status_3a, class: AgentStatus do
    status "Puhelu"
    time_in_status "10"
    association :agent, factory: :agent_3
  end

  factory :status_3b, class: AgentStatus do
    status "Jälkikirjaus"
    time_in_status "10"
    association :agent, factory: :agent_3
  end

end
