class CreateStopEventTable < ActiveRecord::Migration
  def self.up
    create_table :stop_events  do |t|
     t.column "latitude",     :decimal, :precision => 15, :scale => 10
     t.column "longitude",    :decimal, :precision => 15, :scale => 10
     t.column "duration",     :integer
     t.column "device_id",    :integer
     t.column "created_at",  :datetime
    end
  end

  def self.down
    drop_table :stop_events
  end
end
