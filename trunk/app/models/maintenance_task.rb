class MaintenanceTask < ActiveRecord::Base
  belongs_to :device
  include ApplicationHelper
  
  validates_presence_of :description
  
  TYPE_RUNTIME = 0
  TYPE_SCHEDULED = 1
  
  def is_runtime?
    task_type == TYPE_RUNTIME
  end
  
  def is_scheduled?
    task_type == TYPE_SCHEDULED
  end
  
  def update_status(update_time = Time.now)
    return if completed_at

    self.reviewed_at = update_time
    case task_type
      when TYPE_RUNTIME
        self.remind_runtime = self.target_runtime * 0.90 unless self.remind_runtime # set to 90% if uninitialized
        update_reviewed_runtime
        if self.reviewed_runtime > self.target_runtime
          unless self.pastdue_notified
            self.pastdue_notified = self.reviewed_at
            return "Past Due: Maintenance task '#{self.description}' was due after #{(self.target_runtime) / 60 / 60} runtime hours"
          end
        elsif self.reviewed_runtime > self.remind_runtime
          unless self.reminder_notified
            self.reminder_notified = self.reviewed_at
            return "Reminder: Maintenance task '#{self.description}' will be due in about #{(self.target_runtime - self.reviewed_runtime) / 60 / 60} more runtime hours"
          end
        end
      when TYPE_SCHEDULED
        unless self.remind_at
          period = self.target_at - self.established_at
          if period > 6 * 28 * 24 * 60 * 60 * 60 # > 6 months
            self.remind_at = self.target_at.advance(:months => -1)
          elsif period > 28 * 24 * 60 * 60 * 60 # > 1 months
            self.remind_at = self.target_at.advance(:days => -7)
          elsif period > 7 * 60 * 60 * 60 # > 1 week
            self.remind_at = self.target_at.advance(:days => -1)
          else
            self.remind_at = self.target_at # no reminder
          end
        end
        if self.reviewed_at > self.target_at
          unless self.pastdue_notified
            self.pastdue_notified = self.reviewed_at
            return "Past Due: Maintenance task '#{self.description}' was due on #{self.target_at.strftime('%Y-%m-%d')}"
          end
        elsif self.reviewed_at > self.remind_at
          unless self.reminder_notified
            self.reminder_notified = self.reviewed_at
            return "Reminder: Maintenance task '#{self.description}' will be due on #{self.target_at.strftime('%Y-%m-%d')}"
          end
        end
    end
    nil
  end
  
private
  def update_reviewed_runtime
    established_date_string = self.established_at.strftime('%Y-%m-%d %H:%M:%S')
    reviewed_date_string = self.reviewed_at.strftime('%Y-%m-%d %H:%M:%S')

    self.reviewed_runtime = RuntimeEvent.sum('duration',:conditions => "device_id = #{device_id} and created_at >= '#{established_date_string}' and date_add(created_at,interval duration minute) <= '#{reviewed_date_string}'") * 60

    partial_beginning = RuntimeEvent.find(:first,:conditions => "device_id = #{device_id} and created_at < '#{established_date_string}' and date_add(created_at,interval duration minute) > '#{established_date_string}'")
    self.reviewed_runtime += [(partial_beginning.created_at + (partial_beginning.duration * 60)) - self.established_at,0].max if partial_beginning

    partial_ending = RuntimeEvent.find(:first,:conditions => "device_id = #{device_id} and created_at >= '#{established_date_string}' and date_add(created_at,interval duration minute) > '#{reviewed_date_string}'")
    self.reviewed_runtime += [self.reviewed_at - partial_ending.created_at,0].max if partial_ending
    
    active_ending = RuntimeEvent.find(:first,:conditions => "device_id = #{device_id} and duration is null")
    if active_ending
      start_date = [active_ending.created_at,self.established_at].max
      self.reviewed_runtime += [self.reviewed_at - start_date,0].max
    end
  end
end
