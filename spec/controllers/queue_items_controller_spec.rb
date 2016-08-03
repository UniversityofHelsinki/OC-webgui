require 'rails_helper'
require Rails.root.to_s + '/app/controllers/queue_items_controller.rb'
require Rails.root.to_s + '/app/controllers/application_controller.rb'
require Rails.root.to_s + '/app/services/backend_service.rb'

RSpec.describe QueueItemsController, type: :controller do
  render_views

  before(:each) do
    Rails.cache.clear
  end

  context 'has queue' do
    before(:each) do
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
    end

    it 'returns queue items' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to eq([
        {
          'time_in_queue' => 20,
          'team' => 'Team A',
          'language' => 'English'
        },
        {
          'time_in_queue' => 11,
          'team' => 'Team B',
          'language' => 'Finnish'
        }
      ])
    end
  end

  context 'no queue' do
    it 'returns empty array' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_empty
    end
  end
end
