require 'fastercsv'
ResultCount = 25 # Number of results per page

class ReportsController < ApplicationController  
  before_filter :authorize
  before_filter :authorize_device, :except => ['index']
  DayInSeconds = 86400
  NUMBER_OF_DAYS = 7
  MAX_LIMIT = 999 # Max number of results
 
  def index
      @from_reports = true
      @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
      @devices = Device.get_devices(session[:account_id]) # Get devices associated with account            
      @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
     if params[:type]
         updated_device 
     else   
         if session[:gmap_value] == "all" || session[:gmap_value].nil?        
             @groups = @all_groups
             session[:gmap_value] = "all"
             @show_default_devices = true
         elsif session[:gmap_value] == 'default'
             @groups = []  
             @show_default_devices = true
         else
             @groups=Group.find(:all, :conditions=>['id=?',session[:gmap_value]], :order=>'name')                               
             @show_default_devices = false
         end            
     end 
  end

  def updated_device
    if params[:type] == "all"
         session[:gmap_value] = "all"
         @groups= @all_groups          
         @show_default_devices = true
    elsif params[:type] == "default"
         session[:gmap_value] = params[:type]
         @groups = []
         @show_default_devices = true
    else
         @groups=Group.find(:all, :conditions=>['id=?',params[:type]], :order=>'name')
         session[:gmap_value] = params[:type]         
         @show_default_devices = false
     end        
  end
  
  def all               
     get_start_and_end_date
     @device = Device.find(params[:id])     
     @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
     @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
     @readings=Reading.paginate(:per_page=>ResultCount, :page=>params[:page],
                               :conditions => ["device_id = ? and created_at between ? and ?", 
                               params[:id],@start_dt_str, @end_dt_str],:order => "created_at desc")                             
     @record_count = Reading.count('id', 
                                   :conditions => ["device_id = ? and created_at between ? and ?", params[:id],@start_dt_str, @end_dt_str])
     @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data are going to be different in numbers.
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
 
  def stop
    get_start_and_end_date
    @device = Device.find(params[:id])    
    @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
    @stop_events = StopEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
          :conditions => ["device_id = ? and created_at between ? and ?",
           params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")
    @readings = @stop_events      
    @record_count = StopEvent.count('id', :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
 
  def idle
    get_start_and_end_date
    @device = Device.find(params[:id])    
    @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
    @idle_events = IdleEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
         :conditions => ["device_id = ? and created_at between ? and ?",
         params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")    
    @readings = @idle_events
    @record_count = IdleEvent.count('id', :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
  
  def runtime
    get_start_and_end_date
    @device = Device.find(params[:id])    
    @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
    @runtime_events = RuntimeEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
         :conditions => ["device_id = ? and created_at between ? and ?",
          params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")    
    @readings = @runtime_events
    @record_count = RuntimeEvent.count('id', :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
     
  # Display geofence exceptions
  def geofence
    get_start_and_end_date 
    @device = Device.find(params[:id])
    @geofences = Device.find(params[:id]).geofences # Geofences to display as overlays    
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
    @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], 
                              :conditions => ["device_id = ? and created_at between ? and ? and event_type like '%geofen%'",
                              params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")                                             
     @record_count = Reading.count('id', :conditions => ["device_id = ? and event_type like '%geofen%' and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
  end
     
  # Display gpio1 events
  def gpio1
    get_start_and_end_date 
    @device = Device.find(params[:id])    
    @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], 
                              :conditions => ["device_id = ? and created_at between ? and ? and gpio1 is not null",
                              params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")                                             
     @record_count = Reading.count('id', :conditions => ["device_id = ? and gpio1 is not null and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
  end
     
  # Display gpio2 events
  def gpio2
    get_start_and_end_date 
    @device = Device.find(params[:id])    
    @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], 
                              :conditions => ["device_id = ? and created_at between ? and ? and gpio2 is not null",
                              params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")                                             
     @record_count = Reading.count('id', :conditions => ["device_id = ? and gpio2 is not null and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
  end

  # Export report data to CSV 
  def export
    unless params[:page]
      params[:page] = 1
    end    
    # Determine report type so we know what filter to apply
     if params[:type] == 'all'
       event_type = '%'
     elsif params[:type] == 'geofence'
      event_type = '%geofen%'
     end             
     get_start_and_end_date
     if params[:type]=='stop'
         events = StopEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str]})        
     elsif params[:type] == 'idle'
         events = IdleEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str]})                
     elsif params[:type] =='runtime'   
         events = RuntimeEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str]})                        
     else    
         readings = Reading.find(:all,
                      :order => "created_at desc",
                      :offset => ((params[:page].to_i-1)*ResultCount),
                      :limit=>MAX_LIMIT,
                      :conditions => ["device_id = ? and event_type like ? and created_at between ? and ?", params[:id],event_type,@start_dt_str,@end_dt_str])                                
     end   
     # Name of the csv file
     @filename = params[:type] + "_" + params[:id] + ".csv"      
     csv_string = FasterCSV.generate do |csv|
         if ['stop','idle','runtime'].include?(params[:type]) 
           csv << ["Location","#{params[:type].capitalize} Duration (m)","Started","Latitude","Longitude"]  
           events.each do |event|                                              
               local_time = event.get_local_time(event.created_at.in_time_zone.inspect)
               address = event.reading.nil? ? "#{event.latitude};#{event.longitude}" : event.reading.shortAddress
               csv << [address,((event.duration.to_s.strip.size > 0) ? event.duration : 'Unknown'),local_time, event.latitude,event.longitude]
            end
         else
            csv << ["Location","Speed (mph)","Started","Latitude","Longitude","Event Type"] 
            readings.each do |reading|        
               local_time = reading.get_local_time(reading.created_at.in_time_zone.inspect)
                csv << [reading.shortAddress,reading.speed,local_time,reading.latitude,reading.longitude,reading.event_type]
            end        
         end    
     end
     
     send_data csv_string,
         :type => 'text/csv; charset=iso-8859-1; header=present',
         :disposition => "attachment; filename=#{@filename}"
  end
 
  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => ResultCount, :conditions => "event_type='speeding_et40' and device_id='#{params[:id]}'")
  end
 
private

  def get_start_and_end_date
     if !params[:end_date].nil?
             if params[:end_date].class.to_s == "String"
                @end_date = params[:end_date].to_date
                @start_date = params[:start_date].to_date
             else
                @end_date = get_date(params[:end_date])
                @start_date = get_date(params[:start_date])
             end
     else
         @from_normal=true
         @end_date = Date.today
         @start_date =  Date.today -  NUMBER_OF_DAYS
     end
     @start_dt_str = @start_date.to_s + ' 00:00:00'
     @end_dt_str   = @end_date.to_s + ' 23:59:59'
  end

  def get_date(date_inputs)
      date =''     
      date_inputs.each{|key,value|   date= date + value + " "}          
      date=date.strip.split(' ')
      date = "#{date[2]}-#{date[0]}-#{date[1]}".to_date
      return date
  end

end
