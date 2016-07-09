class AddLastReliableStatusToQueueItems < ActiveRecord::Migration
  def change
    add_column :queue_items, :last_reliable_status, :datetime
  end
end
