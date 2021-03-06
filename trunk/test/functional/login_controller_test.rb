require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :users, :accounts
  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    get :index
  end
  
  def test_login
   @request.host="app.ublip.com"
   post :index, {:email => users(:testuser).email, :password => "testing"} 
   assert_redirected_to :controller => "home", :action => "index"
   assert_equal accounts(:app).id, @request.session[:account_id]
   assert_equal users(:testuser).id, @request.session[:user_id]
   assert_equal users(:testuser).id, @request.session[:user]
   assert_equal users(:testuser).email, @request.session[:email]
   assert_equal users(:testuser).first_name, @request.session[:first_name]
   assert_equal users(:testuser).account.company, @request.session[:company]
 end
 
 def test_login_same_email_diff_act
   @request.host="app2.ublip.com"
   post :index, {:email => users(:dennis2).email, :password => "testing"} 
   assert_redirected_to :controller => "home", :action => "index"
   assert_equal accounts(:app2).id, @request.session[:account_id]
   assert_equal users(:dennis2).id, @request.session[:user_id]
   assert_equal users(:dennis2).id, @request.session[:user]
   assert_equal users(:dennis2).email, @request.session[:email]
   assert_equal users(:dennis2).first_name, @request.session[:first_name]
   assert_equal users(:dennis2).account.company, @request.session[:company]
 end
 
 def test_login_wrong_subdomain
   @request.host="app3.ublip.com"
   post :index, {:email => users(:testuser).email, :password => "testing"} 
   assert_redirected_to "/login"
   assert_nil @request.session[:account_id]
   assert_nil @request.session[:user_id]
 end
 
 def test_login_failure
   @request.host="app.ublip.com"
   post :index, {:email => users(:testuser).email, :password => "wrong"} 
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

 def test_admin_login
     @request.host="app4.ublip.com"
     @request.cookies['account_value'] = CGI::Cookie.new('account_value', '4')
     @request.cookies['admin_user_id'] = CGI::Cookie.new('admin_user_id', '1')     
     get :admin_login,{}
     assert_redirected_to(:controller => '/home', :action => 'index')
     assert_equal "testuser@ublip.com",@request.session[:user].email
     assert_equal 4, @request.session[:account_id]
     assert_equal 1, @request.session[:user_id]          
     assert_equal "test", @request.session[:first_name]
     assert_equal "Tracking Co 4", @request.session[:company] 
 end

 def test_admin_login_with_invalid_account_number
     @request.cookies['account_value'] = CGI::Cookie.new('account_value', '12563')
     get :admin_login,{}
     assert_redirected_to(:controller => 'login')
 end

 def test_admin_login_with_null_account
     @request.cookies['account_value'] = CGI::Cookie.new('account_value', nil)
     get :admin_login,{}
     assert_redirected_to(:controller => 'login')
 end
 
end
