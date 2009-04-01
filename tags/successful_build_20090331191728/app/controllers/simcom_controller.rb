class SimcomController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
  
  def index
    @total_devices = Simcom::Device.count
    @total_requests = Simcom::CommandRequest.count
  end
  
end
