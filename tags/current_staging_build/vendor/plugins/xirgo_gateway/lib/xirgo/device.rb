class Xirgo::Device < ActiveRecord::Base
  attr_accessor :friendly_name
  attr_accessor :logical_device
  
  def self.find_device_by_vin(vin)
    latest_reading = Xirgo::Reading.find(:all,:conditions => ['vin = ?',vin],:order => 'timestamp desc',:limit => 1)
    return find(latest_reading[0].device_id) if latest_reading.any?
  end
  
  def request_vin
    Xirgo::CommandRequest.create! :device_id => self.id,:imei => self.imei,:command => VIN_REQUEST,:start_date_time => Time.now
  end
  
  def vin
    @vin_readings ||= Xirgo::Reading.find(:all,:conditions => ['device_id = ? and vin is not null',self.id],:order => 'timestamp desc',:limit => 1)
    @vin_readings[0].vin if @vin_readings.any?
  end

  def last_location_request
    Xirgo::CommandRequest.find(:first,:conditions => {:device_id => self.id,:command => Xirgo::CommandRequest::LOCATION_REQUEST},:order => "start_date_time desc")
  end
  
  def submit_location_request
    Xirgo::CommandRequest.create!(:device_id => self.id,:imei => self.imei,:command => Xirgo::CommandRequest::LOCATION_REQUEST,:start_date_time => Time.now)
  end
end