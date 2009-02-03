class SettingsController < ApplicationController
  def index
    @device_names = Device.get_names(session[:account_id])
  end
end
