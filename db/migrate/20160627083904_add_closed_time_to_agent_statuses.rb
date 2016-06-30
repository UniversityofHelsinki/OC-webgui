class AddClosedTimeToAgentStatuses < ActiveRecord::Migration
  def change
    add_column :agent_statuses, :closed, :datetime
    add_column :agent_statuses, :name, :string
  end
end
