class RegisterController < ApplicationController
  def index
    return unless request.post?
    @vin = params[:vin]
    device = Device.find_device_by_vin(@vin)
    return redirect_to("/register/info/#{device.id}") if device and device.dealer
    flash[:error] = device ? 'VIN is not available' : 'VIN not found'
  end
  
  def info
    @device = Device.find(params[:id])
    @device.name = params[:device_name].blank? ? @device.vin : params[:device_name]
    return redirect_to(:action => 'index') unless @device and @device.dealer and @device.account.dealer
    @user = User.new(params[:user])
    return unless request.post?
    raise 'Your password and confirmation did not match' + params[:user][:password].to_s + ':' + params[:confirm_password].to_s if params[:user].nil? or params[:user][:password] != params[:confirm_password]
    Device.transaction do
      Account.transaction do
        account = Account.create!(:company => @device.vin,:subdomain => @device.vin,:is_verified => true,:dealer => false)
        User.transaction do
          @user.account_id = account.id
          @user.is_admin = true
          @user.save!
        end
        @device.group_id = nil
        @device.account_id = account.id
      end
      @device.dealer = false
      @device.save!
    end
    redirect_to :action => 'thank_you'
  rescue
    flash[:error] = $!.to_s
  end
end
