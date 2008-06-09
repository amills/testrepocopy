require File.dirname(__FILE__) + '/../test_helper'

class MotionNotificationTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users, :accounts, :devices, :stop_events, :motion_events
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

  end
  
  def test_notify
    event = MotionEvent.new
    event.device_id=1
    event.created_at=Time.now
    event.save
    
    event2 = MotionEvent.new
    event2.device_id=2
    event2.created_at=Time.now
    event2.save
    
    event3 = MotionEvent.new
    event3.device_id=3
    event3.notified=true
    event3.created_at=Time.now
    event3.save
    
    assert_equal false, event.notified
    assert_equal false, event2.notified
    
    MotionNotifier.notify_motion_events
    assert_equal 2, ActionMailer::Base.deliveries.size
    
    event.reload
    event2.reload
    
    assert_equal true, event.notified
    assert_equal true, event2.notified
  
  end
  

end
