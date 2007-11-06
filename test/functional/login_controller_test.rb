require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    get :index
  end
  
  def test_login
   @request.host="dennis.ublip.com"
   post :index, {:email => users(:dennis).email, :password => "testing"} 
   assert_redirected_to "/home"
 end
 
 def test_login_same_email_diff_act
   @request.host="nick.ublip.com"
   post :index, {:email => users(:dennis).email, :password => "testing"} 
   assert_redirected_to "/home"
 end
 
 def test_login_failure
   @request.host="dennis.ublip.com"
   post :index, {:email => users(:dennis).email, :password => "wrong"} 
   assert flash[:username]
   assert_redirected_to "/login"
 end
 
 def test_logout
   get :logout
   assert_redirected_to "/login"
 end
 
 def test_change_password
    post :password, {:id => "1", :user => {:password => "newpassword", :password_confirmation =>"newpassword"}}
    user2 = User.find(1)
    assert_equal User.encrypt("newpassword", "salty"), user2.crypted_password
  end
 
end
