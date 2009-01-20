require 'fastercsv'
ResultCount = 25 # Number of results per page

class ReportsController < ApplicationController
  before_filter :authorize
  before_filter :authorize_device, :except => ['index']
  DayInSeconds = 86400
  NUMBER_OF_DAYS = 7
  MAX_LIMIT = 999 # Max number of results

  def index
    @groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    @devices = Device.get_devices(session[:account_id]) # Get devices associated with account    
    redirect_to :action => 'all',:id => @devices[0].id if @devices.any?
  end

  def all
    get_start_and_end_date
    @device = Device.find(params[:id])    
    @device_names = Device.get_names(session[:account_id])
    conditions = get_device_and_dates_conditions
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], :conditions => conditions, :order => "created_at desc")
    @record_count = Reading.count(:conditions => conditions)
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data are going to be different in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end

  # TODO consider how to use the word "task" instead of "reading" for these elements
  def maintenance
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id])
    conditions = ["device_id = ?",params[:id]]
    @readings = MaintenanceTask.paginate(:per_page => ResultCount,:page => params[:page],:conditions => conditions,
      :order => "(completed_at is null) desc,completed_at desc,established_at desc")
    @record_count = MaintenanceTask.count(:conditions => conditions)
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data are going to be different in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
  
  def speeding
    get_start_and_end_date
    @device = Device.find(params[:id])    
    @device_names = Device.get_names(session[:account_id])
    conditions = "#{get_device_and_dates_conditions} and speed > #{(@device.account.max_speed or -1)}"
    @readings=Reading.paginate(:per_page=>ResultCount, :page=>params[:page], :conditions => conditions, :order => "created_at desc")
    @record_count = Reading.count('id', :conditions => conditions)
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data are going to be different in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end
  
  def stop
    get_start_and_end_date
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id])
    conditions = get_device_and_dates_with_duration_conditions
    @stop_events = StopEvent.paginate(:per_page=>ResultCount, :page=>params[:page], :conditions => conditions, :order => "created_at desc")
    @readings = @stop_events
    @record_count = StopEvent.count('id', :conditions => conditions)
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end

  def idle
    get_start_and_end_date
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id])
    conditions = get_device_and_dates_with_duration_conditions
    @idle_events = IdleEvent.paginate(:per_page=>ResultCount, :page=>params[:page], :conditions => conditions, :order => "created_at desc")
    @readings = @idle_events
    @record_count = IdleEvent.count('id', :conditions => conditions)
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end

  def runtime
    get_start_and_end_date
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id])
    conditions = get_device_and_dates_with_duration_conditions
    @runtime_events = RuntimeEvent.paginate(:per_page=>ResultCount, :page=>params[:page],:conditions => conditions,:order => "created_at desc")
    @runtime_total = RuntimeEvent.sum(:duration,:conditions => conditions)
    active_event = RuntimeEvent.find(:first,:conditions => "#{conditions} and duration is null")
    @runtime_total += ((Time.now - active_event.created_at) / 60).to_i if active_event
    @readings = @runtime_events
    @record_count = RuntimeEvent.count('id', :conditions => conditions)
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end

  # Display geofence exceptions
  def geofence
    get_start_and_end_date
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id])
    @geofences = Device.find(params[:id]).geofences # Geofences to display as overlays
    conditions = "#{get_device_and_dates_conditions} and event_type like '%geofen%'"
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], :conditions => conditions, :order => "created_at desc")
    @record_count = Reading.count('id', :conditions => conditions)
    @actual_record_count = @record_count
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end

  # Display gpio1 events
  def gpio1
    get_start_and_end_date
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id])
    conditions = "#{get_device_and_dates_conditions} and gpio1 is not null"
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], :conditions => conditions, :order => "created_at desc")
    @record_count = Reading.count('id', :conditions => conditions)
    @actual_record_count = @record_count
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end

  # Display gpio2 events
  def gpio2
    get_start_and_end_date
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id])
    conditions = "#{get_device_and_dates_conditions} and gpio2 is not null"
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], :conditions => conditions, :order => "created_at desc")
    @record_count = Reading.count('id', :conditions => conditions)
    @actual_record_count = @record_count
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end

  # Export report data to CSV
  def export
    params[:page] = 1 unless params[:page]
    
    case params[:type]
      when 'stop'
        get_start_and_end_date
        return export_events(StopEvent.find(:all, {:order => "created_at desc", :conditions => get_device_and_dates_with_duration_conditions}))
      when 'idle'
        get_start_and_end_date
        return export_events(IdleEvent.find(:all, {:order => "created_at desc", :conditions => get_device_and_dates_with_duration_conditions}))
      when 'runtime'
        get_start_and_end_date
        return export_events(RuntimeEvent.find(:all, {:order => "created_at desc", :conditions => get_device_and_dates_with_duration_conditions}))
      when 'maintenance'
        return export_maintenance
    end

    get_start_and_end_date
    event_type = params[:type] == 'geofence' ? '%geofen%' : '%'
    readings = Reading.find(:all,:order => "created_at desc",:offset => ((params[:page].to_i-1)*ResultCount),:limit=>MAX_LIMIT,
      :conditions => "#{get_device_and_dates_conditions} and event_type like '#{event_type}'")

    # Name of the csv file
    @filename = params[:type] + "_" + params[:id] + ".csv"
    csv_string = FasterCSV.generate do |csv|
      csv << ["Location","Speed (mph)","Started","Latitude","Longitude","Event Type"]
      readings.each do |reading|
        local_time = reading.get_local_time(reading.created_at.in_time_zone.inspect)
        csv << [reading.short_address,reading.speed,local_time,reading.latitude,reading.longitude,reading.event_type]
      end
    end

    send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@filename}"
  rescue
    flash[:error] = $!.to_s
    redirect_to :back
  end

  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => ResultCount, :conditions => "event_type='speeding_et40' and device_id='#{params[:id]}'")
  end

private

  def export_events(events)
    @filename = params[:type] + "_" + params[:id] + ".csv"

    csv_string = FasterCSV.generate do |csv|
      csv << ["Location","#{params[:type].capitalize} Duration (m)","Started","Latitude","Longitude"]
      events.each do |event|
        local_time = event.get_local_time(event.created_at.in_time_zone.inspect)
        address = event.reading.nil? ? "#{event.latitude};#{event.longitude}" : event.reading.short_address
        csv << [address,((event.duration.to_s.strip.size > 0) ? event.duration : 'Unknown'),local_time, event.latitude,event.longitude]
      end
    end

    send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@filename}"
  end
  
  def export_maintenance
    tasks = MaintenanceTask.paginate(:per_page => ResultCount,:page => params[:page],:conditions => ["device_id = ? and completed_at is not null",params[:id]], :order => "completed_at desc")

    @filename = "maintenance_#{params[:id]}.csv"

    csv_string = FasterCSV.generate do |csv|
      csv << ["Maintenance Task","Completed Date","Completed By"]
      tasks.each do |task|
        csv << [task.description,task.completed_at.strftime("%Y-%m-%d"),task.completed_by]
      end
    end

    send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@filename}"
  end
  
  def get_device_and_dates_conditions
    "device_id = #{params[:id]} and created_at between '#{@start_dt_str}' and '#{@end_dt_str}'"
  end
  
  def get_device_and_dates_with_duration_conditions
    return "device_id = #{params[:id]} and ((created_at between '#{@start_dt_str}' and '#{@end_dt_str}') or (duration is null))" if Time.now < @end_dt_str.to_time
    get_device_and_dates_conditions
  end

  def get_start_and_end_date
    case (@time_period = (params[:time_period] || 'hour'))
      when 'hour'
        @end_date_str = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        @start_date_str = (Time.now - 60 * 60).strftime('%Y-%m-%d %H:%M:%S')

        @end_date = Date.today
        @start_date =  Date.today -  NUMBER_OF_DAYS
      when 'day'
        @end_date_str = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        @start_date_str = (Time.now - 24 * 60 * 60).strftime('%Y-%m-%d %H:%M:%S')

        @end_date = Date.today
        @start_date =  Date.today -  NUMBER_OF_DAYS
      else
        if params[:end_date]
          if params[:end_date].class.to_s == "String"
            @end_date = params[:end_date].to_date
            @start_date = params[:start_date].to_date
          else
            @end_date = get_date(params[:end_date])
            @start_date = get_date(params[:start_date])
          end
        else
          @end_date = Date.today
          @start_date =  Date.today -  NUMBER_OF_DAYS
        end
        @start_date,@end_date = @end_date,@start_date if @end_date < @start_date
        @start_dt_str = @start_date.to_s + ' 00:00:00'
        @end_dt_str   = @end_date.to_s + ' 23:59:59'
    end
  end

end
