class CreateEmergencyContacts < ActiveRecord::Migration
  def self.up
    create_table :emergency_contacts do |t|
      t.column :driver_id,:integer,:null => false
      t.column :name,:string
      t.column :home_phone,:string
      t.column :office_phone,:string
      t.column :mobile_phone,:string
      t.column :relationship,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :emergency_contacts
  end
end
