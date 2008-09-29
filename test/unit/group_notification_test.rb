require File.dirname(__FILE__) + '/../test_helper'

class GroupNotificationTest < Test::Unit::TestCase
  fixtures :group_notifications

 context  "notification testing" do    
      setup do
          @logger = ActiveRecord::Base.logger
          @logger.auto_flushing = true
          @logger.info("This notification daemon is still running at #{Time.now}.\n")    
      end
      
        #~ should "send geofence exited on entered notifications " do 
           #~ readings = Notifier.send_geofence_notifications(@logger)
           #~ assert_equal 0, readings.length
        #~ end

        should "send device offline notifications" do
            devices_to_notify = Notifier.send_device_offline_notifications(@logger)
            assert_equal 3,devices_to_notify[0].id
            assert_equal "device 3",devices_to_notify[0].name
        end    
        
        should "send gpio notifications" do
            devices_to_notify = Notifier.send_gpio_notifications(@logger)
            assert_equal 0,devices_to_notify.length
        end
        
        should "send speed notifications" do
            devices_to_notify = Notifier.send_speed_notifications(@logger)
            assert_equal 0,devices_to_notify.length
        end    
  end    
end
