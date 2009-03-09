class AddNotificationText < ActiveRecord::Migration
  def self.up
    add_column :notifications, :notification_text, :string, :limit => 1024
	end

  def self.down
    remove_column :notifications, :notification_text, :string
	end
end
