
class DevicesController < ApplicationController

  before_filter :authorize
  def index
    @devices = Device.get_devices(session[:account_id])
  end
  
  # Device details view
  def view
    @device = Device.get_device(params[:id], session[:account_id])
    @device_names = Device.get_names(session[:account_id])
    @readings = Reading.find(:all, :conditions => ["device_id = ?", @device.id], :limit => 20, :order => "created_at desc")
    render :layout => 'application'
  end
  
  def choose_phone
    if (request.post? && params[:imei] != '')
      device = provision_device(params[:imei])
      if(!device.nil?)
        # Removing for now. Causes 500 error in functional test on build box.
        #Text_Message_Webservice.send_message(params[:phone_number], "please click on http://www.db75.com/downloads/ublip.jad")
        redirect_to :controller => 'devices', :action => 'index'
      end
    end
  end
  
  # A device can provisioned
  def choose_MT
    if (request.post? && params[:imei] != '')
      device = provision_device(params[:imei])
      if(!device.nil?)
        redirect_to :controller => 'devices', :action => 'index'
      end
    end
  end
  
  # User can edit their device
  def edit
    if request.post?
      device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])
      device.name = params[:name]
      device.imei = params[:imei]
      device.save
      flash[:message] = params[:name] + ' was updated successfully'
      redirect_to :controller => 'devices'
    else
      @device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])  
    end
  end
  
  # User can delete their device
  def delete
    if request.post?
      device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])
      device.update_attribute(:provision_status_id, 2) # Let's flag it for now instead of deleting it
      flash[:message] = device.name + ' was deleted successfully'
      redirect_to :controller => "devices"
    end
  end
  
  def provision_device(imei, extras=nil)
    device = Device.find_by_imei(imei) # Determine if device is already in system
        
    # Device is already in the system so let's associate it with this account
    if(device)
      if(device.provision_status_id == 0)
        device.account_id = session[:account_id]
        imei = params[:imei]
        device.name = params[:name]
        device.provision_status_id = 1
        device.save
        flash[:message] = params[:name] + ' was provisioned successfully'
      else
        flash[:message] = 'This device has already been added'
        return nil
      end
      # No device with this IMEI exists so let's add it
    else
      device = Device.new
      device.name = params[:name]
      device.imei = params[:imei]
      if(!extras.nil?)
        device.online_threshold = extras[:online_threshold].nil? ? nil : extras[:online_threshold]
      end
      device.provision_status_id = 1
      device.account_id = session[:account_id]
      device.save
      flash[:message] = params[:name] + ' was created successfully'
    end
    return device
  end
  
   def show_group_by_id
        @group_for_data=Group.find(:all ,:conditions=>["account_id =?" ,session[:account_id]] )
        group_id = []
        count = 0
        for group in @group_for_data
            group_id[count] = group.id
            count = count + 1
        end
        @devices_ids=GroupDevice.find(:all  , :conditions => ['group_id in (?)', group_id])
        group_id = []
        count = 0
        for group in @devices_ids
            group_id[count] = group.device_id
            count = count + 1
        end
        @group_device_ids=GroupDevice.find(:all  ,  :select => 'distinct(device_id)',:conditions => ['device_id in (?)', group_id])
        group_id = []
        count = 0
        for group in @group_device_ids
            group_id[count] = group.device_id
            count = count + 1
        end
        @devices=Device.find(:all , :conditions => [ ' id in (?) AND account_id=?', group_id ,session[:account_id]] )
        if @group_device_ids== nil ||@group_device_ids.length == 0 
           @devices_all = Device.find(:all, :conditions => ["account_id = ?", session[:account_id]])
        else
           @devices_all =Device.find(:all ,:conditions => [ 'account_id = ? AND id not in (?) ',session[:account_id],group_id])
        end

        @all_devices = Device.find(:all, :conditions => ["account_id = ?", session[:account_id]])
        @count_devices = Device.count(:all, :conditions => ["account_id = ?", session[:account_id]])
    end 
   
    def map
        render :action => "devices/map", :layout => "map_only"
    end
    def index
        @devices = Device.get_devices(session[:account_id])
    end
  
  # Device details view
    def view
        @device = Device.get_device(params[:id], session[:account_id])
        @device_names = Device.get_names(session[:account_id])
        @readings = Reading.find(:all, :conditions => ["device_id = ?", @device.id], :limit => 20, :order => "created_at desc")
        render :layout => 'application'
    end
  
    def choose_phone
        if (request.post? && params[:imei] != '')
            device = provision_device(params[:imei])
            if(!device.nil?)
              Text_Message_Webservice.send_message(params[:phone_number], "please click on http://www.db75.com/downloads/ublip.jad")
              redirect_to :controller => 'devices', :action => 'index'
            end
        end
    end

    def create_group
      @groups = Group.find(:all,:conditions=>["account_id=?",session[:account_id]])
    end 


   def show_group_1
      @group_ids=params[:group_id]
      redirect_to :action=>'new_group',:group_id=>@group_ids
   end 

   def groups
      @groups=Group.find(:all  ,:conditions => ["account_id=? ", session[:account_id] ])
   end

   def group_action 
    @user_prefence= params[:type]
    @user_prefence.inspect
    if params[:type] == "all"
       show_group_by_id()   
    elsif params[:type] == "edit"
    else
        @group_for_data=Group.find(:all,:conditions => ["id=? ", @user_prefence ])
        @devices_ids=GroupDevice.find(:all  , :conditions => ['group_id =?', @group_for_data])
        group_id = []
        count = 0
        for group in @devices_ids
            group_id[count] = group.device_id
            count = count + 1
       end  
      @devices=Device.find(:all , :conditions => [ ' id in (?) ', group_id ] )
      @all_devices = Device.find(:all, :conditions => ["account_id = ?", session[:account_id]])
         
     end 
     # redirect_to :controller=>'reading',:action=>'recent'
     render :update do |page|         	 
	 page.replace_html "show_group" , :partial => "show_group_by_id",:locals=>{ :all_devices=>@all_devices,:group_for_data=>@group_for_data ,:devices_ids=>@devices_ids,:devices=>@devices}
	 page.visual_effect :highlight, "show_group"
	 end
	 
 end 



     # new code starts  
     
    def delete_group        
        @group=Group.find(params[:group_id][:id])
        flash[:message]= "Group " + @group.name +  "  was deleted successfully "        
        @group.destroy
        @group_devices = Device.find(:all, :conditions=>['group_id=?',@group.id])
        for device in @group_devices          
          device.icon_id ="1" 
          device.group_id = nil
          device.update
        end  
        redirect_to :action=>"groups"
    end 
          
    def edits_group
         if params[:group_id]
             @group = Group.find_by_id(params[:group_id])                           
         end
        if request.post?
            @group=Group.find(params[:group_id][:id]) 
            save_group
             if !validate_device_ids
                 if @group.save
                     Device.find(:all, :conditions=>['group_id=?',@group.id]).each{|device| device.group_id =nil; device.save}
                     update_devices
                     flash[:message]= "Group " + @group.name + " was updated successfully "
                     redirect_to :action=>"groups"                                
                 end
             else
                 @group = Group.find(@group.id)
                 flash[:group_name] = @group.name
                 redirect_to :action=>"edits_group", :group_id=>@group.id
             end            
        end    
        @devices = Device.find(:all,:conditions => ["account_id=? ", session[:account_id] ])
        @group_devices = Device.find(:all, :conditions=>['account_id=? and group_id is not NULL',session[:account_id]])
    end

    def new_group
         if request.post?
             @group = Group.new()
             save_group
             if !validate_device_ids
                 if @group.save 
                     update_devices
                     flash[:message]="Group " + @group.name + " was successfully added"
                     redirect_to :action=>"groups"
                 end    
             else
                 redirect_to :action=>"new_group"
             end    
         end    
         @devices= Device.find(:all,:conditions => ["account_id=? ", session[:account_id] ])
         @group_devices =Device.find(:all, :conditions=>['account_id=? and group_id is not NULL',session[:account_id]])
     end 
     
     def save_group
         @group.name = params[:group][:name]
         @group.image_value = params[:sel]        
         @group.account_id= session[:account_id]                     
     end
     
     def update_devices
         for device_id in params[:select_devices]
             device = Device.find(device_id)
             device.icon_id = params[:sel]        
             device.group_id = @group.id
             device.update
         end    
     end    
    
     def validate_device_ids
         if  params[:group][:name]=="" || params[:select_devices]== nil || params[:select_devices].length == 0              
             @group.name=="" ? flash[:message] = "Group name can't be blank <br/>" : flash[:message] =""
             flash[:message] << "You must select at least one device "
             flash[:group_name] = @group.name             
             return true
         end   
     end    
     
    #~ def save_group
        #~ @image_value=params[:sel]        
        #~ @device_id= params[:select_devices]
        #~ group_name=params[:group][:name]
        #~ if group_name=="" || @device_id== nil || @device_id.length == 0 
           #~ flash[:message] = "Please enter a group name and you must select at least one device"
           #~ flash[:group_name]= group_name
           #~ redirect_to :action=>"new_group"
        #~ else
        #~ for device_id in @device_id
            #~ devices = Device.find(device_id)
              #~ devices.icon_id =@image_value 
              #~ devices.update
        #~ end    
        #~ @group=Group.new()
        #~ @group.name =group_name
        #~ @group.image_value = @image_value
        #~ @group.account_id= session[:account_id]
  	#~ if @group.save
           #~ if @device_id!= nil && @device_id.length != 0
              #~ for i in 0...@device_id.length do
               #~ #puts @device_id.inspect
                #~ @group_device= GroupDevice.new
                #~ @group_device.account_id=session[:account_id]
                #~ @group_device.group_id=@group.id
                #~ @group_device.device_id=@device_id[i]
                #~ @group_device.save
              #~ end
        #~ end
        #~ flash[:message]="Group " + group_name +" was successfully added"
        #~ redirect_to :action=>"groups"
        #~ else         
       #~ redirect_to :action=>"new_group"
        #~ end
        #~ end
    #~ end 
   
 #~ def update_group
        #~ @group=Group.find(params[:group_id][:id])
        #~ @image_value=params[:sel]
        #~ @device_id= params[:select_devices]
        #~ group_name=params[:group][:name]
        #~ @group.name =group_name
        #~ @group.image_value = @image_value
        #~ @group.account_id= session[:account_id]
        #~ if group_name=="" || @device_id== nil || @device_id.length == 0 
           #~ flash[:message] = "Please enter a group name and you must select at least one device"
           #~ flash[:name]=params[:group][:name]         
           #~ redirect_to :action=>"edits_group", :group_id =>params[:group_id][:id]
        #~ else
           #~ @group.update
           #~ @devices_all =GroupDevice.find(:all ,:conditions => [ 'group_id = ? ',params[:group_id][:id]])
           #~ for device_id in @devices_all
             #~ devices = Device.find(device_id.device_id)
             #~ devices.icon_id ="1" 
             #~ devices.update
          #~ end    
          #~ for device_id in @device_id
            #~ devices = Device.find(device_id)
            #~ devices.icon_id =@image_value
            #~ devices.update
          #~ end    
          #~ @group_device= GroupDevice.find( :all , :conditions =>["group_id= ?" ,params[:group_id][:id]])
          #~ @group_device_id=@group_device
          #~ group_id = []
          #~ count = 0
          #~ for group in @group_device_id
               #~ group_id[count] = group.id
               #~ count = count + 1
          #~ end
          #~ for  group_id in group_id
  	     #~ @group_device_id=   GroupDevice.find(group_id).destroy
  	  #~ end
           #~ if @device_id!= nil && @device_id.length != 0
                #~ for i in 0...@device_id.length do
                          #~ #puts @device_id.inspect
                         #~ @group_device= GroupDevice.new
                         #~ @group_device.account_id=session[:account_id]
                         #~ @group_device.group_id=@group.id
                         #~ @group_device.device_id=@device_id[i]
                      #~ @group_device.save
                #~ end
          #~ end
          #~ flash[:new]= group_name + " was updated successfully "
          #~ redirect_to :action=>"groups"
       #~ end
   #~ end

   #~ def delete_group
        #~ params[:group_id][:id]
        #~ @group=Group.find(params[:group_id][:id])
        #~ flash[:new]= @group.name +  "  was deleted successfully "
        #~ @group.destroy
        #~ @group_devices=GroupDevice.find(:all,:conditions=>["group_id= ?", params[:group_id][:id]])
        #~ @devices_all =GroupDevice.find(:all ,:conditions => [ 'group_id = ? ',params[:group_id][:id]])
        #~ for device_id in @devices_all
          #~ devices = Device.find(device_id.device_id)
          #~ devices.icon_id ="1" 
          #~ devices.update
        #~ end  
        #~ for  group_devices in @group_devices
          #~ group_devices.destroy
        #~ end 
        #~ redirect_to :action=>"group_list"
   #~ end 

    #~ def group_list
      #~ @groups = Group.find(:all,:conditions=>["account_id=?",session[:account_id]])
    #~ end

    #show the current user group
    def show_group
      show_group_by_id()
    end 
  
end
