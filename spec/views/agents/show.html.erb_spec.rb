require 'rails_helper'

RSpec.describe "agents/show", type: :view do
  before(:each) do
    @agent = assign(:agent, Agent.create!(
      :agent_id => 1,
      :name => "Name",
      :team => "Team",
      :status => "Status",
      :time_in_status => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Team/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/2/)
  end
end
