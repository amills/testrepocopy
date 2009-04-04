class Account < ActiveRecord::Base
  has_many :devices
  has_many :users
  has_many :groups
  has_many :drivers
  
  validates_uniqueness_of :subdomain, :case_sensitive => false
  validates_presence_of :company, :message => "Please specify your company or group name"
  validates_presence_of :subdomain, :message => "Please specify a subdomain"
end
