class Enfora::Device < ActiveRecord::Base
  attr_accessor :friendly_name
  attr_accessor :logical_device

  def last_location_request
    Enfora::CommandRequest.find(:first,:conditions => {:device_id => self.id,:command => Enfora::CommandRequest::LOCATION_REQUEST},:order => "start_date_time desc")
  end
  
  def submit_location_request
    Enfora::CommandRequest.create!(:device_id => self.id,:command => Enfora::CommandRequest::LOCATION_REQUEST,:start_date_time => Time.now)
  end
end
