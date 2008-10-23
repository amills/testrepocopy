class Xirgo::DeviceController < Xirgo::CommonController
  def list
    @selections = {}
    @devices = Xirgo::Device.find(:all,:order => "imei")
    return if request.get?
    if params[:device_ids]
      for device_id in params[:device_ids]
        selected_device = Xirgo::Device.find(device_id)
        raise "Xirgo::Device not found: #{device_id}" unless selected_device
        @selections[selected_device.id] = selected_device
      end
    end
    raise "No command specified" unless params[:xt3001] and !params[:xt3001].blank?
    raise "No devices selected" if @selections.empty?
    Xirgo::CommandRequest.transaction do
      start_date_time = Time.now
      @selections.each_value do | device |
        command_request = Xirgo::CommandRequest.new
        command_request.device_id = device.id
        command_request.command = '+XT:3001,' + params[:xt3001]
        command_request.start_date_time = start_date_time
        command_request.save!
      end
    end
    redirect_to :controller => 'command_request',:action => 'list'
  rescue
    test = $!.to_s
    @error = $!.to_s
  end
end
