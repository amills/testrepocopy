class Group < ActiveRecord::Base
 belongs_to :account
 has_many :devices
 validates_presence_of :name
end
