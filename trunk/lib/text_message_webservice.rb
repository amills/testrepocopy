require 'soap/wsdlDriver'

class Text_Message_Webservice
  
  REG_KEY = "EA792DD474E88BE770F1"
  #WSDL = "http://wsparam.strikeiron.com/globalsmspro2_5?WSDL"
  WSDL = "http://api.clickatell.com/soap/webservice.php?WSDL"
  API_ID = 3159034
  USER = "zimtech"
  PWORD = "zim1959"

  def Text_Message_Webservice.send_message(to, text)
    begin
      driver = SOAP::WSDLDriverFactory.new(WSDL).create_rpc_driver
      @results = driver.SendMessage(:UserID => REG_KEY, :ToNumber => to, :MessageText => text).sendMessageResult.messageStatus
      puts @results.statusCode
      puts @results.statusText
      puts @results.statusExtra
      if(@results.statusCode==1 || @results.statusCode==2) 
        return true
      else
        return false
      end
      
    rescue
      return false
    end
      return true
  end
  
  def Text_Message_Webservice.sendMessage(to, text)
	  begin
		  driver = SOAP::WSDLDriverFactory.new(WSDL).create_rpc_driver
		  @results = driver.sendmsg('',API_ID,USER,PWORD,to,'',text,0,1,0,0,3,0,3,0,0,'1234',0,'SMS_TEXT','','',1440)
	#	  @results = driver.sendmsg(:session_id => '',:api_id => API_ID, :user => USER, :password => PWORD, :to => to, :text => text,:from => '8636706227',:concat => 0,:deliv_ack => 1,:callback => 0,:deliv_time => 0,:max_credits => 3,:req_feat => 0,:queue => 3,:escalate => 0,:mo => 0,:CliMsgID => '1234',:unicode => 0,:msg_type => 'SMS_TEXT',:udh => '',:data => '',:validity => 1440)
		  #  puts @results.statusCode
		#  puts @results.statusText
		#  puts @results.statusExtra
		#  if(@results.statusCode==1 || @results.statusCode==2) 
		#	  return true
		#  else
		#	  return false
		#  end
		  
	  rescue
		  return false
	  end
      return true
  end
end