class Xirgo::Device < ActiveRecord::Base
  attr_accessor :friendly_name
  attr_accessor :logical_device
  
  def request_vin
    Xirgo::CommandRequest.create! :device_id => self.id,:imei => self.imei,:command => '+XT:7002',:start_date_time => Time.now
  end
  
  def vin
    @vin_readings ||= Xirgo::Reading.find(:all,:conditions => ['device_id = ? and vin is not null',self.id],:order => 'timestamp desc',:limit => 1)
    @vin_readings[0].vin if @vin_readings.any?
  end
end