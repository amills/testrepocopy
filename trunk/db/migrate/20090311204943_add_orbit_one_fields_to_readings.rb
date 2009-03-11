class AddOrbitOneFieldsToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :battery_status, :integer, :limit => 6
    add_column :readings, :message_count, :integer, :limit => 6
    add_column :readings, :in_motion, :boolean
    add_column :readings, :subsequent_message, :boolean
  end

  def self.down
    remove_column :readings, :battery_status
    remove_column :readings, :message_count
    remove_column :readings, :in_motion
    remove_column :readings, :subsequent_message
  end
end
