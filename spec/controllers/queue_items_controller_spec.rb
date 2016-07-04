require 'rails_helper'
require Rails.root.to_s + '/app/controllers/queue_items_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe QueueItemsController, type: :controller do
  render_views

  it 'queue json should work' do
    item1 = { "line"=>136,
              "label"=>"abc",
              "created_at"=>anything
            }

    item2 = { "line"=>133,
              "label"=>"qwe",
              "created_at"=>anything
            }

    QueueItem.create(line: 136, label: "abc", created_at: Time.at(Time.zone.now.to_i - 20.seconds), open: true)
    QueueItem.create(line: 133, label: "qwe", created_at: Time.at(Time.zone.now.to_i - 11.seconds), open: true)
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

