require File.dirname(__FILE__) + '/../test_helper'

class GroupNotificationTest < Test::Unit::TestCase
  fixtures :group_notifications

  def test_group_notifications
      logger = ActiveRecord::Base.logger
      logger.auto_flushing = true
      logger.info("This notification daemon is still running at #{Time.now}.\n")    
      assert_equal 1, Notifier.send_device_offline_notifications(logger).length                    
      #assert_equal 0, Notifier.send_geofence_notifications(logger).length
      assert_equal 0, Notifier.send_gpio_notifications(logger).length
      assert_equal 0, Notifier.send_speed_notifications(logger).length
  end
  
end
