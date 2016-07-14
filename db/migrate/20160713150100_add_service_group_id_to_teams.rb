class AddServiceGroupIdToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :service_group_id, :integer
  end
end
