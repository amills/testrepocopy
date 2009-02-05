class LocatorsController < ApplicationController
  before_filter :authorize
  before_filter :authorize_device, :except => ['index']
  
  def index
    @device_names = Device.get_names(session[:account_id])
    redirect_to :action => 'edit',:id => @device_names[0].id if @device_names.any?
  end

  def edit
    @device_names = Device.get_names(session[:account_id])
    @device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])
    if @device.nil?
      flash[:error] = 'Invalid action.'
    elsif request.post?
      if @device.update_attributes(params[:device])
        flash[:success] = @device.name + ' was updated successfully'
      else
        flash[:error] =""
        @device.errors.each_full do | err |
          flash[:error] << err + "<br/>"
        end
      end
    end
  end
end
