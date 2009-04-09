class UsersController < ApplicationController
  before_filter :authorize
  before_filter :authorize_user, :except => ['index', 'new']

  def index
    @current_user = User.find(session[:user_id])
    @users = User.find(:all, :conditions => ["account_id = ?", session[:account_id]])
  end

  def edit
    @user = User.find(:first, :conditions => ["id = ? and account_id = ?", params[:id], session[:account_id]])
    if request.post?
      unless @user.id == session[:user_id] or session[:is_admin]
        flash[:error] = 'Only administrators can edit a user other than himself'
        return redirect_to(:controller => 'users', :action => 'edit', :id => @user)
      end

      last_sms_notify = @user.sms_notify
      @user.sms_notify,@user.sms_confirmed = false,false unless @user.sms_number == params[:user][:sms_number] and @user.sms_domain == params[:user][:sms_domain]
      @user.update_attributes(params[:user])
      params[:is_admin] ? @user.is_admin = 1 : @user.is_admin = 0

      if params[:password_checkbox]
        if @user.crypted_password != @user.encrypt(params[:password])
          return flash[:error] = 'Your existing password must match what\'s currently stored in our system'
        elsif params[:new_password] != params[:confirm_new_password] or params[:new_password].blank? or params[:confirm_new_password].blank?
          return flash[:error] = 'Your new password and confirmation must match'
        elsif params[:new_password].length < 6 or params[:new_password].length > 30
          return flash[:error] = 'Passwords must be between 6 and 30 characters'
        else
          @user.password = params[:new_password]
        end
      end
      if @user.save
        flash[:success] = @user.first_name + ' ' + @user.last_name + ' was updated successfully'
        flash[:error] = 'NOTE: Your SMS number/carrier has changed and you must reselect SMS notifications <a href="/settings">here</a>' if last_sms_notify != @user.sms_notify
        redirect_to :controller => 'users'
      else
        errors = []
        @user.errors.each{ |field, msg| errors.push(msg) }
        flash[:error] = errors.join('<br/>')
      end
    end
  end

  def new
    unless session[:is_admin]
      flash[:error] = 'Only administrators can create users'
      return redirect_to(:controller => 'users', :action => 'index')
    end
      
    @user = User.new(params[:user])
    if request.post?
      @user.account_id = session[:account_id]
      if params[:is_admin]
        @user.is_admin = 1
      end
      @users = User.find(:all, :conditions => ['account_id =?', @user.account_id])

      # Check that passwords match
      if params[:user][:password] == params[:user][:password_confirmation]
        if @user.save
          flash[:success] = @user.email + ' was created successfully'
          redirect_to :controller => 'users'
        else # Display errors from model validation
          error_msg = ''
          @user.errors.each_full do |error|
            error_msg += error + '<br />'
          end
          flash[:error] = error_msg
        end
      else
        flash[:error] = 'Your new password and confirmation must match'
      end
    end
  end

  def delete
    unless session[:is_admin]
      flash[:error] = 'Only administrators can delete users'
      return redirect_to(:controller => 'users', :action => 'index')
    end
      
    if request.post?
      user = User.find(params[:id])
      if user.is_master == false
        user.destroy
        flash[:success] = user.email + ' was deleted successfully'
        redirect_to :controller => "users"
      else
        flash[:error] = 'Master user cannot be deleted'
        redirect_to :controller => "users"
      end
    end
  end
end
