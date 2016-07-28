class RenameHandlingEndedToAfterCallEnded < ActiveRecord::Migration
  def change
    rename_column :contacts, :handling_ended, :after_call_ended
    rename_column :contacts, :arrived_in_queue, :arrived
  end
end
