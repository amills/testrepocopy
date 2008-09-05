class CreateArchiveReadings < ActiveRecord::Migration
  def self.up
    create_table :archive_readings do |t|
      t.integer :reading_id        
      t.float :latitude,:longitude, :altitude, :speed, :direction
      t.integer :device_id
      t.string :event_type,  :limit=>25
      t.string :note, :limit=>255
      t.string :address, :limit=>1024
      t.boolean :notified, :default=> 0
      t.boolean :ignition, :gpio1, :gpio2
      t.timestamps
    end
  end

  def self.down
    drop_table :archive_readings
  end
end
