require 'rails_helper'

RSpec.describe "agents/index", type: :view do
  before(:each) do
    assign(:agents, [
      Agent.create!(
        :agent_id => 1,
        :name => "Name",
        :team => "Team",
        :status => "Status",
        :time_in_status => 2
      ),
      Agent.create!(
        :agent_id => 1,
        :name => "Name",
        :team => "Team",
        :status => "Status",
        :time_in_status => 2
      )
    ])
  end

  it "renders a list of agents" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Team".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
