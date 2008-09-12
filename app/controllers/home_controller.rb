class HomeController < ApplicationController
  before_filter :authorize
  
  def index          
      @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
      @devices = Device.get_devices(session[:account_id]) # Get devices associated with account            
      @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
      check_the_session_for_active_group # This will check which group is currently active in the session, For display.
  end
  
  def statistics
    index # TODO add proper query
  end
  
  def maintenance
    index # TODO add proper query
  end
  
  def show_devices         
    @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    @devices = Device.get_devices(session[:account_id]) # Get devices associated with account            
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')        
    assign_the_selected_group_to_session # this will set the parameter value of group to the session for persisit throught the app
    render :action=>'index'
  end
  
  def map
    render :action => "home/map", :layout => "map_only"   
  end
 
end
