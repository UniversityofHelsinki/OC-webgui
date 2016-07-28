FactoryGirl.define do 
  factory :item_1, class: QueueItem do
    service_id '131'
    service_name 'Neuvonta Eng'
    time_in_queue '10'
  end

  factory :item_2, class: QueueItem do
    service_id '161'
    service_name 'Hakijapalvelut Fin'
    time_in_queue '22'
  end

  factory :qitem, class: QueueItem do
    service_id '1'
    open false
  end

end
