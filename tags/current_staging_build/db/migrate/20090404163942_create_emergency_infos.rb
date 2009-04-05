class CreateEmergencyInfos < ActiveRecord::Migration
  def self.up
    create_table :emergency_infos do |t|
      t.column :driver_id,:integer,:null => false
      t.column :age,:integer
      t.column :dob,:datetime
      t.column :illnesses,:string,:limit => 4096
      t.column :medications,:string,:limit => 4096
      t.column :alergies,:string,:limit => 4096
      t.column :blood_type,:string
      t.column :physician_name,:string
      t.column :physician_phone,:string
      t.column :notes,:string,:limit => 4096
      t.timestamps
    end
  end

  def self.down
    drop_table :emergency_infos
  end
end
