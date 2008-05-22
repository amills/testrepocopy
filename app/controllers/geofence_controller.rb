class GeofenceController < ApplicationController
  before_filter :authorize

  def index
    device_ids = Device.get_devices(session[:account_id]).map{|x| x.id}
    @geofences_pages,@geofences = paginate :geofences,:conditions => ["device_id in (#{device_ids.join(',')}) or account_id = ?",session[:account_id]], :order => "name",:per_page => 3
  end
  
  # Adding new method for adding geofences for a device =========@better
  def new
    @devices = Device.get_devices(session[:account_id])
    if request.post?
      geofence = Geofence.new
      add_and_edit(geofence)
      if geofence.save
        flash[:message] = 'Geofence created succesfully'
        redirect_to :controller => 'geofence', :action => 'index'
      else
        flash[:message] = 'Geofence not created'
      end
    end
  end

  def add
    if request.post?
      device = Device.get_device(params[:id], session[:account_id])
      
      begin
        # Get the bounds parameters
        fence = params[:bounds].split(",")
        lat = fence[0]
        lng = fence[1]
        rad = fence[2]
        rad_meters = fence[2].to_f * 1609.344 # 1 mile in meters
        geofence = Geofence.new
        geofence.name = params[:name]
        geofence.latitude= lat
        geofence.longitude = lng
        geofence.radius = rad
        geofence.address = params[:address]
        geofence.device_id = device.id
        begin
          geofence.find_fence_num
        rescue
          flash[:message] = 'You can have a total of four geofences per device'
          redirect_to :controller => 'geofence', :action => 'view', :id => device.id
          return
        end
        
        geofence.save!
        flash[:message] = 'Geofence created succesfully'
      rescue StandardError => error
        flash[:message] = 'Error creating geofence'
        logger.error(error)
      end
        redirect_to :controller => 'geofence', :action => 'view', :id => device.id
    else
      @device = Device.get_device(params[:id], session[:account_id])
    end
  end
  
  #~ def view
    #~ @device = Device.get_device(params[:id], session[:account_id])
    #~ # Send them to the geofence creation form if there aren't any geofences
    #~ if @device.geofences.size == 0
      #~ redirect_to :controller => 'geofence', :action => 'add', :id => @device and return
    #~ end
  #~ end

  
  def detail
    @geofence = Geofence.find(:first,:conditions => ["id = ?",params[:id]])
  end  
  
  def edit # Added new edit method ===========@better
    @devices = Device.get_devices(session[:account_id])
    @geofence = Geofence.find(params[:id])
    if request.post?
      geofence = Geofence.find(params[:id])
      add_and_edit(geofence)
      if geofence.save
        flash[:message] = 'Geofence updated succesfully'
        redirect_to :controller => 'geofence', :action => 'index'
      else
        flash[:message] = 'Geofence not updated'
      end
    end  
  end  
  
  def view   # Added new view method ===========@better

    if (params[:id] =~ /account/)
      id = params[:id].gsub(/account/, '')
      @account = Account.find_by_id(id)
      @geofences_pages, @geofences = paginate :geofences, :conditions=> ["account_id=?", id], :order => "name",:per_page => 15      
    else
      id = params[:id].gsub(/device/, '')
      @device = Device.find_by_id(id)
      @geofences_pages, @geofences = paginate :geofences, :conditions=> ["device_id=?", id], :order => "name",:per_page => 15
    end

  end
  
  # TODO Protect this so the user can't specify an arbritray device and geofence id, tie it to account_id
  #~ def edit
    #~ if request.post?
      #~ begin
        
        #~ # Get the bounds parameters
        #~ fence = params[:bounds].split(",")
        #~ lat = fence[0]
        #~ lng = fence[1]
        #~ rad = fence[2].to_f * 1609.344 # 1 mile in meters
        #~ geofence = Geofence.find(params[:geofence_id], :conditions => ["device_id = ?", params[:device_id]])
        #~ geofence.name = params[:name]
        #~ geofence.latitude= lat
        #~ geofence.longitude = lng
        #~ geofence.radius = rad
        #~ geofence.address = params[:address]
        
        #~ geofence.save
        #~ flash[:message] = 'Geofence updated successfully'
      #~ rescue
        #~ flash[:message] = 'error updating geofence'
      #~ end
      #~ redirect_to :controller => 'geofence', :action => 'view', :id => params[:device_id]
    #~ else
      #~ @geofence = Geofence.find(params[:id]) #params[:geofence_id], :conditions => ["device_id = ?", params[:id ]])
    #~ end
  #~ end
  
  #~ def delete
    #~ if request.post?
      #~ begin
        #~ geofence = Geofence.find(params[:geofence_id], :conditions => ["device_id = ?", params[:device_id]])
        #~ device = Device.get_device(params[:device_id], session[:account_id])
        #~ if(!device.online?) 
          #~ flash[:message] = 'Device appears offline, please try again later'
          #~ redirect_to :controller => 'geofence', :action => 'view', :id => device.id
          #~ return
        #~ end
        #~ Middleware_Gateway.send_AT_cmd('AT%24GEOFNC='+ geofence.fence_num.to_s + ',0,0,0', device)
        #~ Middleware_Gateway.send_AT_cmd('AT%26w', device)
        #~ geofence.destroy
        #~ flash[:message] = 'Geofence deleted successfully'
      #~ rescue
        #~ flash[:message] = 'Error deleting geofence'
      #~ end
      #~ redirect_to :controller => 'geofence', :action => 'view', :id => params[:device_id]
    #~ end
  #~ end
  
  def delete #New delete method ===========@better
    Geofence.delete(params[:id])
    flash[:message] = 'Geofence deleted successfully'
    redirect_to :action => "index"
  end  

private
  
  def add_and_edit(geofence)
    add = params[:address].split(',')
    lat = add[0]
    lng = add[1]
    geofence.name = params[:name]
    geofence.latitude= lat
    geofence.longitude = lng
    geofence.radius = params[:radius]
    geofence.address = params[:address]
    geofence.account_id = params[:radio] == "1" ? session[:account_id] : 0
    geofence.device_id = params[:radio] == "2" ? params[:device]  : 0
  end  
  
end
