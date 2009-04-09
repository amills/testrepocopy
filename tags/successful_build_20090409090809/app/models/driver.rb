class Driver < ActiveRecord::Base
  belongs_to :account
  has_many :emergency_contacts,:dependent => :delete_all
  has_one :emergency_info,:dependent => :delete
  
  validates_presence_of :name,:relationship
end
