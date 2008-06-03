class HomeController < ApplicationController
  before_filter :authorize

  def index
    if !params[:type]
        @devices = Device.get_devices(session[:account_id]) # Get devices associated with account    
        @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]])
        @groups = @all_groups
        @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL',session[:account_id]])    
    else            
        @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]])
        @groups=Group.find(:all, :conditions=>['id=?',params[:type]])
        @default_devices=[]
        render :layout=>false
    end    
  end
  
  def map
   render :action => "home/map", :layout => "map_only"   
  end
 
end
