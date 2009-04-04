class Driver < ActiveRecord::Base
  belongs_to :account
  has_many :emergency_contacts
  has_one :emergency_info
  
  validates_presence_of :name,:relationship
end
