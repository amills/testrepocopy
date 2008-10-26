class MaintenanceTask < ActiveRecord::Base
  belongs_to :device
  
  validates_presence_of :description
  
  TYPE_RUNTIME = 0
  TYPE_SCHEDULED = 1
  
  def is_runtime?
    task_type == TYPE_RUNTIME
  end
  
  def is_scheduled?
    task_type == TYPE_SCHEDULED
  end
end
