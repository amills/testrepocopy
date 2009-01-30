class MaintenanceController < ApplicationController
  before_filter :authorize
  
  def index
    if params[:description]
      conditions = "completed_at is null and exists(select * from devices where device_id = devices.id and account_id = #{current_account.id})"
      @tasks = MaintenanceTask.find(:all,:conditions => conditions,:order => "description")
      @total_tasks = MaintenanceTask.count(:conditions => conditions)
    else
      @tasks = MaintenanceTask.find_by_sql("select description, maintenance_tasks.id, count(*) task_count from maintenance_tasks, devices where device_id = devices.id and account_id = #{current_account.id} and completed_at is null group by description order by description")
      @total_tasks = MaintenanceTask.count_by_sql("select count(*) from maintenance_tasks, devices where device_id = devices.id and account_id = #{current_account.id} and completed_at is null")
    end
  end
  
  def new
    @device = Device.find(params[:id])
    @task = MaintenanceTask.new(:device_id => @device.id)
    @task.description = 'Routine Maintenance'
    @task.established_at = Date.today
    @task.target_runtime = 2000 * 60 * 60
    @task.target_at = Date.today.advance(:months => 6)
    return unless request.post?
    
    @task.description = params[:description]
    @task.task_type = params[:task_type] == 'scheduled' ? MaintenanceTask::TYPE_SCHEDULED : MaintenanceTask::TYPE_RUNTIME
    @task.established_at = get_date(params[:established_at]).to_time
    @task.target_runtime = params[:runtime_hours].to_f * 60 * 60
    @task.target_at = get_date(params[:target_at]).to_time
    @task.update_status
    @task.save!

    flash[:success] = "'#{@task.description}' for #{@device.name} created successfully"
    redirect_to :controller => 'reports',:action => 'maintenance',:id => @device
  rescue
    flash[:error] = $!.to_s
  end
  
  def edit
    @task = MaintenanceTask.find(params[:id])
    return unless request.post?

    @task.description = params[:description]
    @task.task_type = params[:task_type] == 'scheduled' ? MaintenanceTask::TYPE_SCHEDULED : MaintenanceTask::TYPE_RUNTIME
    @task.target_runtime = params[:runtime_hours].to_f * 60 * 60
    @task.target_at = get_date(params[:target_at]).to_time
    @task.remind_runtime = nil
    @task.remind_at = nil
    @task.reminder_notified = nil
    @task.pastdue_notified = nil
    @task.update_status
    @task.save!

    flash[:success] = "'#{@task.description}' for #{@task.device.name} updated successfully"
    redirect_to :controller => 'reports',:action => 'maintenance',:id => @task.device_id
  rescue
    flash[:error] = $!.to_s
  end
  
  def complete
	  @task = MaintenanceTask.find(params[:id])
	  if @task.completed_at
		  flash[:error] = "'#{@task.description}' for #{@task.device.name} has already been completed"
		  redirect_to :controller => 'reports',:action => 'maintenance',:id => @task.device_id
	  end
	  
	  @task.completed_at = Date.today
	  return unless request.post?
	  
	  @task.completed_at = get_date(params[:completed_at])
	  @task.completed_by = session[:email]
	  @task.save!
	  @task.reload
	  # TODO calculate reviewed_runtime
	  new_date = @task.completed_at + (@task.completed_at - @task.established_at)
	  new_task = MaintenanceTask.create!(:device_id => @task.device_id,:description => @task.description,:task_type => @task.task_type,:established_at => @task.completed_at,:target_runtime => @task.target_runtime,:target_at => new_date,:reviewed_at => Time.now)
	  
	  flash[:success] = "'#{@task.description}' for #{@task.device.name} completed successfully, and a new task has been started."
	  redirect_to :action => 'edit',:id => new_task
  rescue
	  flash[:error] = $!.to_s
  end
  def delete
	  unless session[:is_admin]
		  flash[:error] = 'Only administrators can delete maintenance tasks'
		  return redirect_to(:controller => 'reports', :action => 'maintenance', :id => task.device_id)
	  end
      
	  if request.post?
		  task = MaintenanceTask.find(params[:id])
		  task.destroy
		  flash[:success] = task.description + ' was deleted successfully'
		  redirect_to(:controller => 'reports', :action => 'maintenance', :id => task.device_id)
	  end
  end
  end