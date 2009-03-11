class Device < ActiveRecord::Base
  STATUS_INACTIVE = 0
  STATUS_ACTIVE   = 1
  STATUS_DELETED  = 2
  
  REPORT_TYPE_ALL       = 0
  REPORT_TYPE_STOP      = 1
  REPORT_TYPE_IDLE      = 2
  REPORT_TYPE_SPEEDING  = 3
  REPORT_TYPE_RUNTIME   = 4
  REPORT_TYPE_GPIO1     = 5
  REPORT_TYPE_GPIO2     = 6

  belongs_to :account
  belongs_to :group
  belongs_to :profile,:class_name => 'DeviceProfile'
  
  validates_uniqueness_of :imei
  validates_presence_of :name, :imei
  
  has_one :latest_gps_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "latitude is not null"
  has_one :latest_speed_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "speed is not null"
  has_one :latest_data_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "ignition is not null"
  has_one :latest_idle_event, :class_name => "IdleEvent", :order => "created_at desc"
  has_one :latest_runtime_event, :class_name => "RuntimeEvent", :order => "created_at desc"
  has_one :latest_stop_event, :class_name => "StopEvent", :order => "created_at desc"
  
  has_many :geofences, :order => "created_at desc", :limit => 300
  has_many :notifications, :order => "created_at desc"
  has_many :stop_events, :order => "created_at desc"
  has_many :pending_tasks,:class_name => "MaintenanceTask",:conditions => "completed_at is null",:order => "pastdue_notified desc,reminder_notified desc,established_at desc"
  
  def self.logical_device_for_gateway_device(gateway_device)
    return gateway_device.logical_device if gateway_device.logical_device

    logical_device = find(:first,:conditions => "imei = '#{gateway_device.imei}'")

    # NOTE: ensure that SOMETHING is set as the logical device
    return (gateway_device.logical_device = new(:name => 'Not Found')) unless logical_device
    
    logical_device.gateway_device = gateway_device
    gateway_device.logical_device = logical_device
  end

  def self.friendly_name_for_gateway_device(gateway_device)
    return 'Undefined' unless gateway_device
    return gateway_device.friendly_name if gateway_device.friendly_name
    logical_device = logical_device_for_gateway_device(gateway_device)
    gateway_device.friendly_name = logical_device.name ? logical_device.name : 'Unassigned'
  end
  
  # For now the provision_status_id is represented by
  # 0 = unprovisioned
  # 1 = provisioned
  # 2 = device deleted by user
  def self.get_devices(account_id)
    find(:all, :conditions => ['provision_status_id = 1 and account_id = ?', account_id], :order => 'name',:include => :profile)
  end
  
  def self.get_public_devices(account_id)
    find(:all, :conditions => ['provision_status_id = 1 and account_id = ? and is_public = 1', account_id], :order => 'name')
  end
  
  def self.get_device(device_id, account_id)
    find(device_id, :conditions => ['provision_status_id = 1 and account_id = ?', account_id])
  end
  
  # Get names/ids for list box - don't want to get an entire devices object
  def self.get_names(account_id)
    find_by_sql(["select id, name from devices where account_id = ? and provision_status_id = 1 order by name", account_id])
  end
  
  def is_power_key_enabled?
    gateway_device_config and gateway_device_config.powerKeyEnabled == 1
  end
  
  def set_power_key(enable)
    gateway_device.set_power_key(enable) if gateway_device and gateway_device.respond_to?('set_power_key')
  end
  
  def battery_level
    return gateway_device.powerState if gateway_device and gateway_device.respond_to?('powerState')
  end
  
  def is_sos_enabled?
    gateway_device_config and gateway_device_config.functionKeyEnabled and gateway_device_config.functionKeyMode == Simcom::DeviceConfig::FK_MODE_SOS
  end
  
  def sos_status_reading
    Reading.find(:first,:conditions => ["device_id = ? and event_type = 'SOS' and created_at >= ?",self.id,Time.now.advance(:hours => -24)])
  end
  
  def is_speed_enabled?
    gateway_device_config and gateway_device_config.functionKeyEnabled and gateway_device_config.functionKeyMode == Simcom::DeviceConfig::FK_MODE_SOS
  end
  
  def speed_status_reading
    Reading.find(:first,:conditions => ["device_id = ? and event_type = 'Speeding' and created_at >= ?",self.id,Time.now.advance(:hours => -24)])
  end
  
  def request_location
    gateway_device.request_location if gateway_device and gateway_device.respond_to?('request_location')
  end
  
  def ensure_gateway_device
    return gateway_device if gateway_device
    gateway = Gateway.find(gateway_name)
    new_statement = %[#{gateway.device_class}.create!(:imei => '#{imei}')]
    @gateway_device = eval(new_statement)
    @gateway_device.logical_device = self
    @gateway_device
  end
  
  def gateway_device
    return if @gateway_device == :false
    return @gateway_device if @gateway_device
    return unless (gateway = Gateway.find(gateway_name))
    find_statement = %[#{gateway.device_class}.find(:first,:conditions => "imei = '#{imei}'")]
    @gateway_device = (eval(find_statement) or :false)
    return if @gateway_device == :false
    @gateway_device.logical_device = self
    @gateway_device
  end
  
  def gateway_device_config
    return if @gateway_device_config == :false
    return @gateway_device_config if @gateway_device_config
    @gateway_device_config = gateway_device.device_config if gateway_device.respond_to?('device_config')
    @gateway_device_config ||= :false
    return if @gateway_device_config == :false
    @gateway_device_config
  end
  
  def gateway_device=(value)
    @gateway_device = value
  end
  
  def gateway_device_msisdn
    return gateway_device.msisdn if gateway_device and gateway_device.respond_to?('msisdn')
  end
  
  def gateway_device_msisdn=(value)
    return unless gateway_device and gateway_device.respond_to?('msisdn')
    gateway_device.msisdn = value
    gateway_device.save
  end
  
  def get_fence_by_num(fence_num)
    Geofence.find(:all, :conditions => ['device_id = ? and fence_num = ?', id, fence_num])[0]
  end
  
  def last_offline_notification
    Notification.find(:first, :order => 'created_at desc', :conditions => ['device_id = ? and notification_type = ?', id, "device_offline"])
  end
  
  def latest_status
    [REPORT_TYPE_ALL,latest_gps_reading.event_type] if latest_gps_reading
  end
  
  def online?
    if(online_threshold.nil?)
       return true
    end
  
    if(!last_online_time.nil? && Time.now-last_online_time < online_threshold*60)
       return true
     else
      return false
    end
  end
end