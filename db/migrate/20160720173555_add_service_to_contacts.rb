class AddServiceToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :service_id, :int
    add_column :contacts, :contact_type, :string

    remove_column :contacts, :phone_number
  end
end
