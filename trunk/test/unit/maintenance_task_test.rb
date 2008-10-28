require File.dirname(__FILE__) + '/../test_helper'

class MaintenanceTaskTest < ActiveSupport::TestCase
  fixtures :devices,:maintenance_tasks,:runtime_events

  def test_reviewed_runtime
    task = maintenance_tasks(:one)
    assert_equal nil,task.update_status
    assert_equal (20 * 60),task.reviewed_runtime
    
    task = maintenance_tasks(:two)
    assert_equal nil,task.update_status
    assert_equal (10 * 60),task.reviewed_runtime
    
    task = maintenance_tasks(:three)
    assert_equal nil,task.update_status(task.established_at.advance(:hours => 1))
    assert_equal (10 * 60),task.reviewed_runtime
    
    task = maintenance_tasks(:four)
    assert_equal nil,task.update_status(task.established_at.advance(:days => 1))
    assert_equal (8 * 60 * 60),task.reviewed_runtime
    
    task = maintenance_tasks(:five)
    assert_equal nil,task.update_status(task.established_at.advance(:hours => 1))
    assert_equal (60 * 60),task.reviewed_runtime
  end
end
