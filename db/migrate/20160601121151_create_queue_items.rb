class CreateQueueItems < ActiveRecord::Migration
  def change
    create_table :queue_items do |t|
      t.integer :line
      t.string :label
      t.integer :time_in_queue

      t.timestamps null: false
    end
  end
end
