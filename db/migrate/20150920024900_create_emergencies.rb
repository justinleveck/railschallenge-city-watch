class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.string :code, unique: true
      t.integer :fire_severity
      t.integer :police_severity
      t.integer :medical_severity

      t.timestamps null: false
    end
  end
end
