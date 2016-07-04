class AddLastReliableStatusToAgentStatuses < ActiveRecord::Migration
  def change
    add_column :agent_statuses, :last_reliable_status, :datetime
  end
end
