class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :agent_id
      t.integer :ticket_id
      t.datetime :arrived_in_queue
      t.datetime :forwarded_to_agent
      t.datetime :answered
      t.datetime :call_ended
      t.datetime :handling_ended
      t.string :direction
      t.string :phone_number

      t.timestamps null: false
    end
  end
end
