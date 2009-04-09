class EmergencyController < ApplicationController
  before_filter :authorize
  before_filter :authorize_driver,:except => [:edit_contact,:delete_contact]

  def index
    @drivers = Driver.find(:all,:conditions => {:account_id => session[:account_id]})
  end

  def contacts
    @drivers = Driver.find(:all,:conditions => {:account_id => session[:account_id]})
    @current_driver = Driver.find(params[:id]) unless params[:id].blank?
    @current_driver ||= @drivers[0]
    return flash[:error] = %[There are currently no drivers for this account. Click <a href="/emergency/new_driver">here</a> to create one.] unless @current_driver
    flash[:error] = %[There are currently no Emergency Contacts for this driver. Click <a href="/emergency/new_contact/#{@current_driver.id}">here</a> to create one.] if @current_driver.emergency_contacts.empty?
  end
  
  def info
    @drivers = Driver.find(:all,:conditions => {:account_id => session[:account_id]})
    @current_driver = Driver.find(params[:id]) unless params[:id].blank?
    @current_driver ||= @drivers[0]
    return flash[:error] = %[There are currently no drivers for this account. Click <a href="/emergency/new_driver">here</a> to create one.] unless @current_driver
    return flash[:error] = %[There are currently no Emergency Information for this driver. Click <a href="/emergency/update_info/#{@current_driver.id}">here</a> to provide it.] unless @current_driver.emergency_info
    @info = @current_driver.emergency_info
  end
  
  def new_driver
    flash[:error] = nil
    @driver = Driver.new(params[:driver])
    @driver.primary = current_account.drivers.empty?
    @driver.relationship = 'self' if @driver.primary
#    raise 'Dealer accounts do not have drivers' if current_account.dealer
    return unless request.post?
    @driver.save!
    flash[:success] = 'Driver successfully created'
    redirect_to :action => 'index'
  rescue
    flash[:error] = $!.to_s
  end
  
  def edit_driver
    flash[:error] = nil
    @driver = Driver.find(params[:id])
    return unless request.post?
    @driver.update_attributes!(params[:driver])
    flash[:success] = 'Driver successfully updated'
    redirect_to :action => 'index'
  rescue
    flash[:error] = $!.to_s
  end
  
  def delete_driver
    unless session[:is_admin]
      flash[:error] = 'Only administrators can delete drivers'
      return redirect_to(:action => 'index')
    end
      
    if request.post?
      driver = Driver.find(params[:id])
      driver.destroy
      flash[:success] = 'Driver was deleted successfully'
      redirect_to :action => 'index'
    end
  end
  
  def new_contact
    flash[:error] = nil
    @driver = Driver.find(params[:id])
    @contact = EmergencyContact.new(params[:contact])
    return unless request.post?
    @contact.save!
    flash[:success] = 'Emergency Contact successfully created'
    redirect_to :action => 'contacts',:id => @driver.id
  rescue
    flash[:error] = $!.to_s
  end
  
  def edit_contact
    flash[:error] = nil
    @contact = EmergencyContact.find(params[:id])
    @driver = @contact.driver
    return unless request.post?
    @contact.update_attributes!(params[:contact])
    flash[:success] = 'Emergency Contact successfully updated'
    redirect_to :action => 'contacts',:id => @contact.driver_id
  rescue
    flash[:error] = $!.to_s
  end
  
  def delete_contact
    unless session[:is_admin]
      flash[:error] = 'Only administrators can delete emergency contacts'
      return redirect_to(:action => 'index')
    end
      
    if request.post?
      contact = EmergencyContact.find(params[:id])
      contact.destroy
      flash[:success] = 'Emergency contact was deleted successfully'
      redirect_to :action => 'index'
    end
  end
  
  def update_info
    flash[:error] = nil
    @driver = Driver.find(params[:id])
    @info = @driver.emergency_info
    @info ||= EmergencyInfo.new
    return unless request.post?
    @info.dob = get_date(params[:dob])
    @info.update_attributes!(params[:info])
    flash[:success] = 'Emergency Contact successfully updated'
    redirect_to :action => 'info',:id => @driver.id
  rescue
    flash[:error] = $!.to_s
  end

end
