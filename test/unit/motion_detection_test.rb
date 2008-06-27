require File.dirname(__FILE__) + '/../test_helper'

class MotionDetectionTest < Test::Unit::TestCase
  
  fixtures :devices, :readings, :stop_events, :motion_events
  
  def setup
    run_sql("stop_detection.sql")
    run_sql("motion_detection.sql")
    Reading.delete_all
  end
  
  def test_insert_stop
    
    now = Time.now
    device = devices(:device2)
    
    save_reading(15, 32.833781, -96.756807, now) 
    device.reload
    assert_equal 0, device.stop_events.count
    
    save_reading(0, 32.933781, -96.756807, now + 60)
    device.reload
    assert_equal 0, device.stop_events.count
    
    save_reading(0, 32.933781, -96.756807, now + 120)
    device.reload
    assert_equal 0, device.stop_events.count
    
    reading = save_reading(0, 32.933781, -96.756807, now + 700)
    device.reload
    assert_equal 1, device.stop_events.count
    event = device.stop_events[0]
    assert_equal reading.latitude, event.latitude
    assert_equal reading.longitude, event.longitude
    assert_equal (now+60).to_s, event.created_at.to_s
    assert_nil event.duration
    
    reading = save_reading(0, 32.933781, -96.756807, now + 800)
    device.reload
    assert_equal 1, device.stop_events.count
    event = device.stop_events[0]
    assert_nil event.duration
    
    assert_equal 0, device.motion_events.count
    
    save_reading(20, 32.934781, -96.756807, now + 900)
    device.reload
    assert_equal 1, device.stop_events.count
    event = device.stop_events[0]
    assert_equal 14, event.duration
    
    assert_equal 1, device.motion_events.count
    motion_event = device.motion_events[0]
    assert_equal (now+900).to_s, motion_event.created_at.to_s
    assert_equal false, motion_event.notified
    assert_equal reading.latitude, motion_event.latitude
    assert_equal reading.longitude, motion_event.longitude
    
  end
  
  def save_reading(speed, latitude, longitude, created)
    reading = Reading.new
    reading.speed = speed
    reading.latitude = latitude
    reading.longitude = longitude
    reading.device_id = 2
    reading.created_at = created
    reading.save
    reading.reload
    return reading
  end
  
  def run_sql(filename)
    file = File.new(filename)
    file.readline
    file.readline  #skip 1st two lines of file
    sql = file.read
    statements = sql.split(';;')
    
    statements.each  {|stmt| 
      #puts stmt
      ActiveRecord::Base.connection.execute(stmt)
    }
  end
  
end
