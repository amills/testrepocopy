class CreateDrivers < ActiveRecord::Migration
  def self.up
    create_table :drivers do |t|
      t.column :account_id,:integer,:null => false
      t.column :name,:string
      t.column :address,:string
      t.column :city,:string
      t.column :state,:string
      t.column :zip,:string
      t.column :home_phone,:string
      t.column :office_phone,:string
      t.column :mobile_phone,:string
      t.column :relationship,:string
      t.column :emergency_contacts_notes,:string,:limit => 4096
      t.column :primary,:boolean,:null => false,:default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :drivers
  end
end
