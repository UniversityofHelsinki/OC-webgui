FactoryGirl.define do 
  factory :item_1, class: QueueItem do
    line '131'
    label 'Neuvonta Eng'
    time_in_queue '10'
  end

  factory :item_2, class: QueueItem do
    line '161'
    label 'Hakijapalvelut Fin'
    time_in_queue '22'
  end

end
