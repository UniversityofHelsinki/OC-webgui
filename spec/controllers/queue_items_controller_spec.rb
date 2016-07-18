require 'rails_helper'
require Rails.root.to_s + '/app/controllers/queue_items_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe QueueItemsController, type: :controller do
  include Now
  render_views

  it 'queue json should work' do
    item1 = { "service_id"=>136,
              "created_at"=>anything,
              "team"=>"Team A"
            }

    item2 = { "service_id"=>133,
              "created_at"=>anything,
              "team"=>"Team A"
            }

    Team.create(id: 1, name: "Team A")
    Service.create(id: 136, name: "A", team_id: 1)
    Service.create(id: 133, name: "B", team_id: 1)

    QueueItem.create(service_id: 136, label: "abc", created_at: now - 20.seconds, open: true)
    QueueItem.create(service_id: 133, label: "qwe", created_at: now - 11.seconds, open: true)
    get :index, format: :json
    queueitems = JSON.parse(response.body)

    expect(queueitems).to include(item1)
    expect(queueitems).to include(item2)
  end

  it 'queue json should work with empty queue' do
    expected = []

    get :index, format: :json
    queueitems = JSON.parse(response.body)

    expect(queueitems).to eq(expected)
  end
end

