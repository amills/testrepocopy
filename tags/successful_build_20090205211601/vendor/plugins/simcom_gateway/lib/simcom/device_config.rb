require 'simcom/device'

class Simcom::DeviceConfig < ActiveRecord::Base

  FK_MODE_GEOFENCE  = 0
  FK_MODE_SOS       = 1
  
  belongs_to :device
end
