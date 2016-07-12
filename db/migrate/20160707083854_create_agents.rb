class CreateAgents < ActiveRecord::Migration
  def up
    create_table :agents do |t|
      t.string :first_name
      t.string :last_name
      t.references :team, index: true, foreign_key: true

      t.timestamps null: false
    end

    AgentStatus.all.each do |agent_status|
      Agent.find_or_create(agent_status.agent_id, agent_status.name, agent_status.team)
    end

    remove_column :agent_statuses, :team
    remove_column :agent_statuses, :name

    add_foreign_key :agent_statuses, :agents
    add_foreign_key :contacts, :agents
  end

  def down
    add_column :agent_statuses, :team, :string
    add_column :agent_statuses, :name, :string

    remove_foreign_key :agent_statuses, :agents
    remove_foreign_key :contacts, :agents

    drop_table :agents
  end
end
