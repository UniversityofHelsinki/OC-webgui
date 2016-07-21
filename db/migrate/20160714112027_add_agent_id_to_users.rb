class AddAgentIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :agent_id, :int
    add_column :agents, :user_id, :int

    add_foreign_key :agents, :users
    add_foreign_key :users, :agents
  end
end
