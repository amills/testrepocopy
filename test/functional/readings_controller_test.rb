require File.dirname(__FILE__) + '/../test_helper'
require 'readings_controller'

# Re-raise errors caught by the controller.
class ReadingsController; def rescue_action(e) raise e end; end

class ReadingsControllerTest < Test::Unit::TestCase
  
  fixtures :users,:accounts
  
  def setup
    @controller = ReadingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_last
    @request.host="dennis.ublip.com"
    @request.env["Authorization"] = "Basic " + Base64.encode64("dennis@ublip.com:testing")
    get :last, { :id => "1"}, {:user => users(:dennis), :user_id => users(:dennis), :account_id => accounts(:dennis)}
    puts @response.body
    
    assert_select "channel>item" do |element|
       assert_tag :tag => "georss:point", :content => "32.6358 -97.1757"
    end
  end
  
  def test_last_not_auth
    @request.host="dennis.ublip.com"
    @request.env["Authorization"] = "Basic " + Base64.encode64("dennis@ublip.com:testing")
    get :last, { :id => "7"}, {:user => users(:dennis), :user_id => users(:dennis), :account_id => accounts(:dennis)}
    puts @response.body
    
    assert_select "channel" do |element|
    element[0].children.each do |tag|
           if tag.class==HTML::Tag && tag.name=="item"
             fail("should not return any content")
           end
    end
      
    end
  end
  
end
