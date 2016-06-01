require 'rails_helper'

RSpec.describe "agents/edit", type: :view do
  before(:each) do
    @agent = assign(:agent, Agent.create!(
      :agent_id => 1,
      :name => "MyString",
      :team => "MyString",
      :status => "MyString",
      :time_in_status => 1
    ))
  end

  it "renders the edit agent form" do
    render

    assert_select "form[action=?][method=?]", agent_path(@agent), "post" do

      assert_select "input#agent_agent_id[name=?]", "agent[agent_id]"

      assert_select "input#agent_name[name=?]", "agent[name]"

      assert_select "input#agent_team[name=?]", "agent[team]"

      assert_select "input#agent_status[name=?]", "agent[status]"

      assert_select "input#agent_time_in_status[name=?]", "agent[time_in_status]"
    end
  end
end
