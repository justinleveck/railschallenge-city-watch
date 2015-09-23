class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.string :emergency_code
      t.string :type
      t.string :name
      t.integer :capacity
      t.boolean :on_duty, default: false

      t.timestamps null: false
    end
  end
end
