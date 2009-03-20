class CreateMaintenanceTasks < ActiveRecord::Migration
  def self.up
    create_table :maintenance_tasks do |t|
      t.column "device_id",:integer
      t.column "description",:string,:null => false
      t.column "task_type",:integer,:null => false,:default => MaintenanceTask::TYPE_RUNTIME
      t.column "established_at",:datetime,:null => false
      t.column "remind_at",:datetime
      t.column "remind_runtime",:integer
      t.column "target_at",:datetime
      t.column "target_runtime",:integer
      t.column "reviewed_at",:datetime
      t.column "reviewed_runtime",:integer,:default => 0
      t.column "completed_at",:datetime
      t.column "completed_by",:string
      t.column "completed_runtime",:integer
      t.column "reminder_notified",:datetime
      t.column "pastdue_notified",:datetime
    end
  end

  def self.down
    drop_table :maintenance_tasks
  end
end
