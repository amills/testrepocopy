# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require File.dirname(__FILE__) + '/../test_helper'

class RecentReadingTriggerTest < Test::Unit::TestCase

  def setup
    Account.delete_all
    Device.delete_all
    Reading.delete_all 
    file = File.new("db_procs.sql")
    file.readline
    file.readline  #skip 1st two lines of file
    sql = file.read
    sql.strip!
    statements = sql.split(';;')

    statements.each  {|stmt|
      ActiveRecord::Base.connection.execute(stmt)
    }
  end

  context "a current reading inserted" do
    setup do
      @device = Factory.create(:device)
      @reading = Factory.create(:reading, :device => @device)
    end

    should "update the recent reading ID on the device" do
      @device.reload
      assert_equal @reading.id, @device.recent_reading_id
    end
  end

  context "an old reading inserted" do
    setup do
      @device = Factory.create(:device)
      @reading = Factory.create(:reading, :device => @device)
      @old_reading = Factory.create(:reading, :device => @device, :created_at => Time.now-10)
    end

    should "not update the recent reading id" do
      @device.reload
      assert_not_equal @old_reading.id, @device.recent_reading_id
      assert_equal @reading.id, @device.recent_reading_id
    end

  end

end
