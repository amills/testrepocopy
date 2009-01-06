require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  def setup
    account = Factory.create(:account, :subdomain => 'dennis', :is_verified => true)
    @dennis = Factory.create(:user, :account => account, :first_name => 'dennis', :last_name => 'baldwin', :password => 'testing',  :email => 'dennis@ublip.com')
  end

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    @dennis.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal @dennis, User.authenticate('dennis', 'dennis@ublip.com', 'new password')
  end

  def test_should_not_rehash_password
    @dennis.update_attributes(:first_name => 'dennis2')
    assert_equal @dennis, User.authenticate('dennis', 'dennis@ublip.com', 'testing')
  end
  
  def test_should_not_authenticate_user
    assert_nil User.authenticate('dennis', 'dennis@ublip.com', 'badpassword')
  end

  def test_should_authenticate_user
    assert_equal @dennis, User.authenticate('dennis', 'dennis@ublip.com', 'testing')
  end
  
  def test_should_set_remember_token
    @dennis.remember_me
    assert_not_nil @dennis.remember_token
    assert_not_nil @dennis.remember_token_expires_at
  end

  def test_should_unset_remember_token
    @dennis.remember_me
    assert_not_nil @dennis.remember_token
    @dennis.forget_me
    assert_nil @dennis.remember_token
  end
  
  def test_save
    @dennis.password = 'testing'
    @dennis.save!
  end
  
  def test_edit
    assert_equal 'dennis', @dennis.first_name
    assert_equal 'baldwin', @dennis.last_name
    assert_equal User.encrypt('testing', @dennis.salt), @dennis.crypted_password
    @dennis.first_name = 'dennis2'
    @dennis.last_name = 'baldwin2'
    @dennis.save!
  end
  
  def test_generate_token
    user = User.new
    assert_equal("7981aa86aba493c6b4a2c4a2b6cd20b43cccaa9a".class, user.generate_security_token(1).class)
  end
  
  def test_change_password
    user = User.new
    user.change_password("qwerty123", "qwerty123")
    assert_equal(user.password, "qwerty123", "qwerty123")
    assert_equal(user.password_confirmation, "qwerty123", "qwerty123")
  end
  
  def test_remember_token
    user = User.new
    pretend_now_is(Time.at(1185490000)) do
      user.remember_me
      assert_equal true, user.remember_token?
    end
    pretend_now_is(Time.at(1185490000+172800)) do #two days later
       assert_equal false, user.remember_token?
    end
  end

  protected
    def create_user(options = {})
      User.create({ :email => 'quire@example.com', :password => 'quire2', :password_confirmation => 'quire2', :first_name => 'Dennis', :last_name => 'Baldwin' }.merge(options))
    end
end
