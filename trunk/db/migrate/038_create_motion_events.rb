class CreateMotionEvents < ActiveRecord::Migration
  def self.up
    create_table :motion_events do |t|
      t.column "latitude",     :float
      t.column "longitude",    :float
      t.column "notified",     :boolean, :default => false
      t.column "device_id",    :integer
      t.column "created_at",  :datetime
    end
  end

  def self.down
    drop_table :motion_events
  end
end
