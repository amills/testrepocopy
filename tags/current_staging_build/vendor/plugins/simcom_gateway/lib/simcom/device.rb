require 'simcom/device_config'

class Simcom::Device < ActiveRecord::Base
  attr_accessor :friendly_name
  attr_accessor :logical_device
  
  has_one :device_config
  
  def set_power_key(enable)
    Simcom::CommandRequest.create!(:device_id => self.id,:command => "",:start_date_time => Time.now)
  end
end
