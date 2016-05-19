class CreateTestis < ActiveRecord::Migration
  def change
    create_table :testis do |t|
      t.string :name
      t.string :city
      t.integer :age

      t.timestamps null: false
    end
  end
end
