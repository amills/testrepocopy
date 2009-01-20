require 'enfora/device'

class Enfora::CommandRequest < ActiveRecord::Base
  set_table_name "outbound"
  
  LOCATION_REQUEST = "at$gpsrd=1"
  
  belongs_to :device
  
  def friendly_status
    case status
      when 'N/A'
        return 'In Progress'
      else
        return 'Success' if status.index('AT->') == 0
        return status
    end
  end
end
