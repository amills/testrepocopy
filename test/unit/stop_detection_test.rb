# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require File.dirname(__FILE__) + '/../test_helper'

class StopDetectionTest < Test::Unit::TestCase
  self.use_transactional_fixtures = false


  def setup
    Account.delete_all
    Device.delete_all
    Reading.delete_all
    StopEvent.delete_all 
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

  context "The stop detection procedure" do
    context "with xirgo devices" do
      setup do
        account = Factory.create(:account)
        @device1 = Factory.create(:device, :gateway_name => "xirgo", :account => account)
        @reading1 = Factory.create(:reading, :device => @device1, :speed => 0, :latitude =>1, :longitude =>2, :created_at => Time.now-250)
        @reading1.connection.execute("call create_stop_events();")
      end
      should "create stop events" do
        @device1.reload
        assert_equal 1, @device1.stop_events.size
        @reading1.connection.execute("call create_stop_events();")
        @device1.reload
        assert_equal 1, @device1.stop_events.size, "should not duplicate stop event"
      end
    end

    context "with enfora devices" do
      setup do
        account = Factory.create(:account)
        @device1 = Factory.create(:device, :gateway_name => "enfora", :account => account)
        @reading1 = Factory.create(:reading, :device => @device1, :speed => 0, :latitude =>1, :longitude =>2, :created_at => Time.now-250)
        @reading1.connection.execute("call create_stop_events();")
      end
      should "not create stop events" do
        @device1.reload
        assert_equal 0, @device1.stop_events.size
      end
    end
  end
end
