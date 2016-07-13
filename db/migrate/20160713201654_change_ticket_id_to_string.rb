class ChangeTicketIdToString < ActiveRecord::Migration
  def up
    change_column :contacts, :ticket_id, :string
  end

  def down
    change_column :contacts, :ticket_id, :integer
  end
end
