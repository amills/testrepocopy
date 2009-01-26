class AddNotificationsToAccounts < ActiveRecord::Migration
  def self.up
	  add_column :accounts, :show_notifications, :boolean, :default => false 
  end

  def self.down
 	  remove_column :accounts, :show_notifications
	end
end