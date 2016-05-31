class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.integer :agent_id
      t.string :name
      t.string :team
      t.string :status
      t.integer :time_in_status

      t.timestamps null: false
    end
  end
end
