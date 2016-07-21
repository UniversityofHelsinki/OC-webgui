class AddLanguageToService < ActiveRecord::Migration
  def change
    add_column :services, :language, :string
  end
end
