# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require File.dirname(__FILE__) + '/../test_helper'

class TripTest < Test::Unit::TestCase
  self.use_transactional_fixtures = false


  def setup
    Account.delete_all
    Device.delete_all
    Reading.delete_all
    StopEvent.delete_all
    TripEvent.delete_all
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

  context "A device" do
      setup do
        account = Factory.create(:account)
        @device1 = Factory.create(:device, :gateway_name => "xirgo", :account => account)
        @reading1 = Factory.create(:reading, :device => @device1, :speed => 0, :latitude =>1, :longitude =>2, :created_at => Time.now-250)
      end
      context "with an ignition off" do
        setup {Factory.create(:reading, :device => @device1, :speed => 0, :latitude =>1, :longitude =>2, :created_at => Time.now-250, :ignition => 0)}
        should "not create a trip" do
          assert_equal 0, @device1.trip_events.size
        end
      end
      context "With a new ignition on" do
        setup {@reading1 = Factory.create(:reading, :device => @device1, :speed => 0, :latitude =>1, :longitude =>2, :created_at => Time.now-250, :ignition => 1)}
        should "start a new trip" do
          assert_equal 1, @device1.trip_events.size
        end
    end
    context "with a complete set of on...off readings" do
      setup do
        Factory.create(:reading, :device => @device1, :speed => 0, :ignition => 1, :latitude =>1, :longitude =>2, :created_at => Time.now-180)
        Factory.create(:reading, :device => @device1, :speed => 10,:ignition => 1, :latitude =>1, :longitude =>2, :created_at => Time.now-150)
        Factory.create(:reading, :device => @device1, :speed => 0, :ignition => 0,:latitude =>1, :longitude =>2, :created_at => Time.now)
      end
      should "create and close a trip event" do
        @device1.reload
        assert_equal 1, @device1.trip_events.size
        assert_equal 3, @device1.trip_events[0].duration
      end
    end
  end
end
