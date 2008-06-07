class MotionNotifier
  
  
  def MotionNotifier.notify_motion_events
    logger = ActiveRecord::Base.logger
    logger.info("notifiying for motion events...")
    puts "notifying for motion events"
    events_to_notify = MotionEvent.find(:all, :conditions => "notified='0'")
    events_to_notify.each do |event|
      event.device.account.users.each do |user|
        if(user.enotify?)
          logger.info("device moved, notifying: #{user.email}\n")
          mail = Notifier.deliver_motion_event(user, event.device)
        end
      end
    end
  end
  
end