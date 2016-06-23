class CreateAgentStatuses < ActiveRecord::Migration
  def change
    create_table :agent_statuses do |t|
      t.integer :agent_id
      t.string :team
      t.string :status
      t.boolean :open

      t.timestamps null: false
    end
  end
end
