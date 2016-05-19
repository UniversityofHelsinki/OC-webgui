require "rails_helper"

RSpec.describe TestisController, :type => :controller do
  describe "GET index" do
    it "has a 200 status code" do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe "GET index in JSON form" do
  	it "returns a JSON format reply" do
  		get :index, { format: :json  }
  		expect(response.content_type).to eq "application/json"
  	end
  end
end