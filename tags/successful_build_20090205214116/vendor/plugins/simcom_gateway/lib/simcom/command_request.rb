require 'simcom/device'

class Simcom::CommandRequest < ActiveRecord::Base
  set_table_name "outbound"
  
  belongs_to :device
end
