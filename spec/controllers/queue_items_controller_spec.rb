require "rails_helper"
require_relative "../../app/controllers/queue_items_controller.rb"
require_relative "../../app/controllers/application_controller.rb"
require_relative "../../app/services/backend_service.rb"

RSpec.describe QueueItemsController, type: :controller do
  render_views

  before(:each) do
    Rails.cache.clear
  end

  it 'queue json should work' do
    expected = [{:line => "136",
                 :label => "sssssssss",
                 :time_in_queue => "265"},

                {:line => "133",
                 :label => "zzzzz",
                 :time_in_queue => "73"}]

    expected_ilman_kaksoispisteitä = 
               [{"line" => 136,
                 "label" => "sssssssss",
                 "time_in_queue" => 265},

                {"line" => 133,
                 "label" => "zzzzz",
                 "time_in_queue" => 73}]

    BackendService.any_instance.stub(:get_general_queue).and_return(expected)
    
    get :index, format: :json
    queueitems = JSON.parse(response.body)
 
    expect(queueitems).to eq(expected_ilman_kaksoispisteitä)
  end

  it 'queue json should work with empty queue' do
    expected = []
    
    BackendService.any_instance.stub(:get_general_queue).and_return(expected)
    
    get :index, format: :json
    queueitems = JSON.parse(response.body)
 
    expect(queueitems).to eq(expected)
  end
end

