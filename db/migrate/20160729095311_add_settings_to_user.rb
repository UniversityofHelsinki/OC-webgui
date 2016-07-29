class AddSettingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :settings, :json, null: false, default: '{}'
  end
end
