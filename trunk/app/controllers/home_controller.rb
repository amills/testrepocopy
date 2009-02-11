class HomeController < ApplicationController
  before_filter :authorize
  
  def index    
    @device_count = Device.count(:all, :conditions => ['provision_status_id = 1 and account_id = ?', session[:account_id]])
    @all_devices=Device.find(:all, :conditions=>['account_id=? and provision_status_id=1',session[:account_id]], :order=>'name', :include => :profile)                           
    assign_the_selected_group_to_session 
  end
  
  def show_devices                 
    params[:group_type].nil? || params[:group_type]=="all" ?  session[:group_value]="all" : session[:group_value] = params[:group_type]
    redirect_to :action=>'index'
  end
  
  def map
    render :action => "home/map", :layout => "map_only"   
  end

  def update_now
    device = Device.find(params[:id])
    device.request_location
    render :update do |page|
      page.replace_html "update_now_#{device.id}", :partial => 'update_requested'
    end
  end
 
end




