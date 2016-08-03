require 'rails_helper'
require Rails.root.to_s + '/app/controllers/queue_items_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe QueueItemsController, type: :controller do
  render_views

  time = Time.parse('2016-07-11T10:30:46.000Z')

  before(:each) do
    Rails.cache.clear
  end

  it 'queue json should work' do
    item1 = { "time_in_queue"=>20,
              "team"=>"Team A",
              "language"=>"English"
            }

    item2 = { "time_in_queue"=>11,
              "team"=>"Team B",
              "language"=>"Finnish"
            }

    Rails.cache.write('queue_items', [
      {
        time_in_queue: 20,
        team: 'Team A',
        language: 'English'
      },
      {
        time_in_queue: 11,
        team: 'Team B',
        language: 'Finnish'
      }
    ])

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

