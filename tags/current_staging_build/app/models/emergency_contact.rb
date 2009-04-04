class EmergencyContact < ActiveRecord::Base
  belongs_to :driver
  
  validates_presence_of :name,:relationship
end
