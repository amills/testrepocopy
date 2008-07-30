class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    create_table "accounts", :force => true do |t|
      t.column "company",          :string,   :limit => 75
      t.column "address",          :string,   :limit => 50
      t.column "city",             :string,   :limit => 50
      t.column "state",            :string,   :limit => 25
      t.column "zip",              :string,   :limit => 15
      t.column "subdomain",        :string,   :limit => 100
      t.column "updated_at",       :datetime
      t.column "created_at",       :datetime
      t.column "is_verified",      :boolean,                 :default => false
      t.column "is_deleted",       :boolean,                 :default => false
      t.column "show_idle",        :boolean,                 :default => false
      t.column "show_runtime",     :boolean,                 :default => false
      t.column "show_statistics",  :boolean,                 :default => false
      t.column "show_maintenance", :boolean,                 :default => false
    end

    create_table "devices", :force => true do |t|
      t.column "name",                :string,   :limit => 75
      t.column "imei",                :string,   :limit => 30
      t.column "phone_number",        :string,   :limit => 20
      t.column "recent_reading_id",   :integer,                :default => 0
      t.column "created_at",          :datetime
      t.column "updated_at",          :datetime
      t.column "provision_status_id", :integer,  :limit => 2,  :default => 0
      t.column "account_id",          :integer,                :default => 0
      t.column "last_online_time",    :datetime
      t.column "online_threshold",    :integer,                :default => 90
      t.column "icon_id",             :integer,                :default => 1
      t.column "group_id",            :integer
      t.column "is_public",           :integer,                :default => 0
      t.column "device_id", :string, :limit => 25
      t.column "ip_address", :string, :limit => 16
      t.column "port", :integer
      t.column "last_received", :datetime
    end

    create_table "devices_users", :force => true do |t|
      t.column "device_id", :integer
      t.column "user_id",   :integer
    end

    create_table "geofence_violations", :id => false, :force => true do |t|
      t.column "device_id",   :integer, :null => false
      t.column "geofence_id", :integer, :null => false
    end

    create_table "geofences", :force => true do |t|
      t.column "name",       :string,   :limit => 30
      t.column "device_id",  :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "address",    :string
      t.column "fence_num",  :integer
      t.column "latitude",   :decimal,                :precision => 15, :scale => 10
      t.column "longitude",  :decimal,                :precision => 15, :scale => 10
      t.column "radius",     :float
      t.column "account_id", :integer
    end

    create_table "group_devices", :force => true do |t|
      t.column "device_id",  :integer
      t.column "group_id",   :integer
      t.column "account_id", :integer
      t.column "created_at", :datetime
    end

    create_table "group_notifications", :force => true do |t|
      t.column "user_id",    :integer
      t.column "group_id",   :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    create_table "groups", :force => true do |t|
      t.column "name",        :string
      t.column "image_value", :integer
      t.column "account_id",  :integer
      t.column "created_at",  :datetime
    end

    create_table "idle_events", :force => true do |t|
      t.column "latitude",   :float
      t.column "longitude",  :float
      t.column "duration",   :integer
      t.column "device_id",  :integer
      t.column "reading_id", :integer
      t.column "created_at", :datetime
    end

    create_table "notifications", :force => true do |t|
      t.column "user_id",           :integer
      t.column "device_id",         :integer
      t.column "created_at",        :datetime
      t.column "notification_type", :string,   :limit => 25
    end

    create_table "orders", :force => true do |t|
      t.column "account_id", :integer
      t.column "paypal_id",  :string,   :limit => 50
      t.column "created_at", :datetime
    end

    create_table "readings", :force => true do |t|
      t.column "latitude",   :float
      t.column "longitude",  :float
      t.column "altitude",   :float
      t.column "speed",      :float
      t.column "direction",  :float
      t.column "device_id",  :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "event_type", :string,   :limit => 25
      t.column "note",       :string
      t.column "address",    :string,   :limit => 1024
      t.column "notified",   :boolean,                  :default => false
      t.column "device_id", :string, :limit => 25
      t.column "acceleration", :float
      t.column "deacceleration", :float
      t.column "hdop", :float
      t.column "numberOfSatelites", :integer
      t.column "rpm", :float
      t.column "mileage", :float
    end

    add_index "readings", ["device_id", "created_at"], :name => "readings_device_id_created_at"
    add_index "readings", ["device_id"], :name => "readings_device_id"
    add_index "readings", ["created_at"], :name => "readings_created_at"
    add_index "readings", ["address"], :name => "readings_address"
    add_index "readings", ["notified", "event_type"], :name => "readings_notified_event_type"

    create_table "runtime_events", :force => true do |t|
      t.column "latitude",   :float
      t.column "longitude",  :float
      t.column "duration",   :integer
      t.column "device_id",  :integer
      t.column "reading_id", :integer
      t.column "created_at", :datetime
    end

    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data",       :text
      t.column "updated_at", :datetime
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table "stop_events", :force => true do |t|
      t.column "latitude",   :float
      t.column "longitude",  :float
      t.column "duration",   :integer
      t.column "device_id",  :integer
      t.column "created_at", :datetime
      t.column "reading_id", :integer
    end

    create_table "users", :force => true do |t|
      t.column "first_name",                :string,   :limit => 30
      t.column "last_name",                 :string,   :limit => 30
      t.column "email",                     :string
      t.column "crypted_password",          :string,   :limit => 40
      t.column "salt",                      :string,   :limit => 40
      t.column "created_at",                :datetime
      t.column "updated_at",                :datetime
      t.column "remember_token",            :string
      t.column "remember_token_expires_at", :datetime
      t.column "account_id",                :integer
      t.column "is_master",                 :boolean,                :default => false
      t.column "is_admin",                  :boolean,                :default => false
      t.column "last_login_dt",             :datetime
      t.column "enotify",                   :integer,  :limit => 1,  :default => 0
      t.column "time_zone",                 :string
      t.column "is_super_admin",            :boolean,                :default => false
      t.column "access_key",                :string
    end
    
  end
  
  def self.down
    drop_table :accounts
    drop_table :devices
    drop_table :devices_users
    drop_table :geofence_violations
    drop_table :geofences
    drop_table :group_devices
    drop_table :group_notifications
    drop_table :groups
    drop_table :idle_events
    drop_table :notifications
    drop_table :orders
    drop_table :readings
    drop_table :runtime_events
    drop_table :sessions
    drop_table :stop_events
    drop_table :users
  end
end
  
  