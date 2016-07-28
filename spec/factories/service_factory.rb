FactoryGirl.define do 

  factory :team_for_services, class: Team do
    id 1
    name 'Helpdesk'
    initialize_with { Team.where(:id => id).first_or_create }
  end

  factory :service_1, class: Service do
    id 1
    name 'Neuvonta Fin'
    team_id 1
    language 'Finnish'
    initialize_with { Service.where(:id => id).first_or_create }
  end

  factory :service_2, class: Service do
    id 2
    name 'Neuvonta Eng'
    team_id 1
    language 'English'
    initialize_with { Service.where(:id => id).first_or_create }
  end

end
