class CreateNotificationModes < ActiveRecord::Migration
  def self.up
    create_table :notification_modes do |t|
      t.column "user_id",:integer
	  t.column "report",:integer, :limit => 1, :default => NotificationMode::PRIORITY_INFO
	  t.column "email",:integer, :limit => 1, :default => NotificationMode::PRIORITY_INFO
	  t.column "sms",:integer, :limit => 1, :default => NotificationMode::PRIORITY_NONE
	  t.column "voice",:integer, :limit => 1, :default => NotificationMode::PRIORITY_NONE
      t.timestamps
    end
  end

  def self.down
    drop_table :notification_modes
  end
end
