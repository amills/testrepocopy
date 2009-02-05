class Simcom::CommonController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'

  helper_method :predefined_commands,:predefined_command_options,:predefined_command_name
  
  PREDEFINED_COMMANDS = [
    {:command => 'GTSRI:navseeker.apn.telenor.se:::209.20.66.153:7070',:name => 'Server Registration',:advice => 'This command is only valid for NavSeeker using the current STAGING server'},
    {:command => 'GTTRI:0000:2359:5:300',:name => 'Report every 5 minutes'},
    {:command => 'GTTRI:0000:2359:60:3600',:name => 'Report every 60 minutes'},
    {:command => 'GTTRI:0000:2359:360:21600',:name => 'Report every 6 hours'},
    {:command => 'GTTRI:0000:2359:1440:86400',:name => 'Report every 24 hours'},
    {:command => 'GTTRI:0000:0000:0:0',:name => 'Turn off reporting'},
    {:command => 'GTRTO:0',:name => 'Request gps time'},
    {:command => 'GTRTO:1',:name => 'Request real time locate'},
    {:command => 'GTRTO:2',:name => 'Request all device configurations'},
    {:command => 'GTRTO:3',:name => 'Soft reset device'},
    {:command => 'GTRTO:4',:name => 'Hard reset device'},
    {:command => 'GTRTO:5',:name => 'Request ICCID'},
    {:command => 'GTRTO:6',:name => 'Request IMEI'},
    {:command => 'GTRTO:7',:name => 'Request software version'},
    {:command => 'GTRTO:8',:name => 'Request hardware version'},
    {:command => 'GTRTO1:9:1:60',:name => 'Set speed threshold to 60kph',:advice => 'You can replace "60" with any speed'},
    {:command => 'GTRTO1:9:0:0',:name => 'Disable speed threshold'},
    {:command => 'GTSFR:1:1:1:1:5:100',:name => 'Set special functions',:advice => 'The command format is "GTSFR:[power key disable/enable 0/1]:[function key disable/enable 0/1]:[function key mode 0=geofence0, 1=sos]:[movement detect enable 0/1]:[speed kph]:[distance meters]", so this specific command will 1) enable the power key, 2) enable the function key, 3) set function mode to SOS, and 4) enable movement detection at 5kph and 100m'},
  ]
  
  def predefined_command_name(command)
    return unless command
    PREDEFINED_COMMANDS.detect {|entry| return entry[:name] if entry[:command] == command}
  end
  
  def predefined_commands
    PREDEFINED_COMMANDS
  end

  def predefined_command_options
    result = PREDEFINED_COMMANDS.inject(["<option>Select command...</option>"]) {|result,entry| result.push "<option value='#{entry[:command]}'>#{entry[:name]}</option>"}
    result.join
  end
end
