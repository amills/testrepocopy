require 'xirgo/device'

class Xirgo::CommandRequest < ActiveRecord::Base
  belongs_to :device
  
  LOCATION_REQUEST = "+XT:7001"
  VIN_REQUEST = "+XT:7002"
  
  set_table_name "outbound"
  
  def friendly_status
    return status
  end
end
