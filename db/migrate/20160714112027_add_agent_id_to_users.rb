class AddAgentIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :agent_id, :int
  end
end
