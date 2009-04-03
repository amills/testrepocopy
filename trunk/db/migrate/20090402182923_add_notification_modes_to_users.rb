class AddNotificationModesToUsers < ActiveRecord::Migration
  def self.up
	  add_column :users, :byreport,:integer, :limit => 1, :default => NotificationMode::PRIORITY_INFO
	  add_column :users, :byemail,:integer, :limit => 1, :default => NotificationMode::PRIORITY_INFO
	  add_column :users,:bysms,:integer, :limit => 1, :default => NotificationMode::PRIORITY_NONE
	  add_column :users, :byvoice,:integer, :limit => 1, :default => NotificationMode::PRIORITY_NONE
  end

  def self.down
  	  remove_column :users, :byreport
	  remove_column :users, :byemail
	  remove_column :users, :bysms
	  remove_column :users, :byvoice
  end
end
