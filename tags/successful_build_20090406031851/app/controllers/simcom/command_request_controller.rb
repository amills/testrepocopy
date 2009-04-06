class Simcom::CommandRequestController < Simcom::CommonController

  def compose
    @command_request = Simcom::CommandRequest.new(:device_id => params[:id])
  end
  
  def submit
    @command_request = Simcom::CommandRequest.new(params[:command_request])
    @command_request.note = @command_request.command
    @command_request.start_date_time = Time.now
    @command_request.save!
    redirect_to :action => "check_status",:id => @command_request
  rescue
    @error = $!.to_s
    @command_request ||= Simcom::CommandRequest.new
  end

  def upload
    @command_request = Simcom::CommandRequest.find(params[:id])
    if request.post?
      command_found = false
      @expect = 'OK'
      @script = []
      params[:file].each do | line |
        line.strip!
        entry = {:line => line}
        entry[:comment] = line[/\#.*/]
        line = line[/^[^#]*/].strip if entry[:comment]
        if line.blank?
          entry[:blank] = true
        elsif line[0,1] == '!'
          @expect = line[1,line.length - 1].upcase
          next
        else
          entry[:command] = line
          entry[:expect] = @expect
          command_found = true
        end
        @script.push(entry)
      end
      return if command_found
      @script = nil
      @error = "No commands found"
    end
  rescue
    @error = $!.to_s
    @command_request ||= Simcom::CommandRequest.new
  end
  
  def script
    @command_request = Simcom::CommandRequest.find(params[:id])
  rescue
    @error = $!.to_s
    @command_request ||= Simcom::CommandRequest.new
  end
  
  def list
    @device = Simcom::Device.find(params[:id]) if params[:id]
    @device ||= Simcom::Device.new
    conditions = "device_id = #{@device.id}" if @device.id
    @command_requests = Simcom::CommandRequest.find(:all,:conditions => conditions,:order => "start_date_time desc")
  end
  
  def check_status
    @command_request = Simcom::CommandRequest.find(params[:id])
    @device = (@command_request.device or Device.new)
  rescue
    @error = $!.to_s
    @command_request ||= Simcom::CommandRequest.new
    @device ||= Device.new
  end
end
