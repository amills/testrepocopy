class UpdateLatLonPrecision < ActiveRecord::Migration
  def self.up
    change_column :readings,:latitude,:decimal,:precision => 20,:scale => 16
    change_column :readings,:longitude,:decimal,:precision => 20,:scale => 16
    change_column :readings,:altitude,:decimal,:precision => 20,:scale => 16
  end

  def self.down
  end
end
