require File.dirname(__FILE__) + '/../test_helper'
require 'devices_controller'

# Re-raise errors caught by the controller.
class DeviceController; def rescue_action(e) raise e end; end

class DeviceControllerTest < Test::Unit::TestCase 

  fixtures :users,:devices,:accounts

  def setup
    @controller = DevicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_index
    get :index, {}, { :user => users(:dennis) } 
    assert_response :success
  end
  
  def test_index_notauthorized
    get :index
    assert_redirected_to :controller => "login"
  end
  
  def test_edit_post
    post :edit, {:id => "1", :name => "qwerty", :imei=>"000000"}, { :user => users(:dennis), :account_id => "1" }
    assert_equal devices(:device1).name, "qwerty"
    assert_equal devices(:device1).imei, "000000"
    assert_redirected_to :controller => "devices"
  end
  
  def test_edit_get
    get :edit, {:id => "1"}, { :user => users(:dennis), :account_id => "1" }
    assert_equal devices(:device1).name, "device 1"
    assert_equal devices(:device1).imei, "1234"
    assert_response :success
  end
  
  def test_delete
    post :delete, {:id => "1"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "devices"
    assert_equal devices(:device1).provision_status_id, 2
  end
  
  def test_choose
    post :choose, {:imei => "33333", :name => "device 1"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "devices"
    assert_equal devices(:device5).provision_status_id, 1
    assert_equal devices(:device5).account_id, 1
  end
  
  def test_choose_new
    post :choose, {:imei => "314159", :name => "new device"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "devices"
    newDevice = Device.find_by_imei("314159")
    assert_equal newDevice.provision_status_id, 1
    assert_equal newDevice.account_id, 1
  end
  
  def test_choose_already_provisioned
    post :choose, {:imei => "1234"}, { :user => users(:dennis), :account_id => "1" }
    assert_equal flash[:message] , 'This device has already been added'
    assert_response :success
  end
  
end
