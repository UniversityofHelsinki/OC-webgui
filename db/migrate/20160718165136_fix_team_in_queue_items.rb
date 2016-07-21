class FixTeamInQueueItems < ActiveRecord::Migration
  def up
    remove_column :queue_items, :team
    remove_column :queue_items, :label
    remove_column :queue_items, :time_in_queue
    remove_column :queue_items, :line
    add_column :queue_items, :service_id, :integer
    add_foreign_key :queue_items, :services
  end

  def down
    remove_column :queue_items, :service_id
    add_column :queue_items, :team, :string
    add_column :queue_items, :label, :string
    add_column :queue_items, :time_in_queue, :integer
    add_column :queue_items, :line, :integer
  end
end
