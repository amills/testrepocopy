class Account < ActiveRecord::Base
  has_many :devices
  has_many :users
  has_many :groups
  validates_uniqueness_of :subdomain, :case_sensitive => false, :message => "Please choose another subdomain; this one is already taken"
  validates_presence_of :zip, :message => "Please specify your zip code"
  validates_presence_of :company, :message => "Please specify your company or group name"
  validates_presence_of :subdomain, :message => "Please specify a subdomain"
  
  # TODO eliminate the show_idle field with some future migration; it's not worth making a migration just for that...
end
