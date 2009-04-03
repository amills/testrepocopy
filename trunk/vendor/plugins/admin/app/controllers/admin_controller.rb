class AdminController < ApplicationController
  unloadable # making unloadable per http://dev.rubyonrails.org/ticket/6001
  before_filter :authorize_super_admin
  
  def index
    @total_accounts = Account.count(:conditions => "is_deleted = 0")
    @total_users = User.count 
    @total_devices = Device.count(:conditions => "provision_status_id = 1")
    @total_device_profiles = DeviceProfile.count
  end

end