require 'simcom/device_config'

class Simcom::Device < ActiveRecord::Base
  attr_accessor :friendly_name
  attr_accessor :logical_device
  
  has_one :device_config
  
  def set_power_key(enable)
    return unless device_config
    device_config.powerKeyEnabled = enable ? 1 : 0
    device_config.save
    submit_command("GTSFR:#{device_config.powerKeyEnabled}:#{device_config.functionKeyEnabled}:#{device_config.functionKeyMode}:#{device_config.movementDetectionMode}:#{device_config.movementDetectionSpeed}:#{device_config.movementDetectionDistance}")
  end
  
  def submit_command(command)
    Simcom::CommandRequest.create!(:device_id => self.id,:command => command,:note => command,:start_date_time => Time.now)
  end
end
