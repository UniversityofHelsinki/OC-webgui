class AddTeamToQueueItems < ActiveRecord::Migration
  def change
    add_column :queue_items, :team, :string
    add_column :queue_items, :open, :boolean
    add_column :queue_items, :closed, :datetime
  end
end
