function select_action(obj,from)
{  
  var Index = document.getElementById("type1").selectedIndex;
  var selected_text = document.getElementById("type1").options[Index].text;              
    if (selected_text == "New group")
    {
         szNewURL = "http://"+document.location.hostname+"/devices/new_group"         
        window.location.href=szNewURL;            
    }
    else if (selected_text == "Edit groups")
    {
         szNewURL = "http://"+document.location.hostname+"/devices/groups" 
        window.location.href=szNewURL;                
    }
    else
    {
      if (from=='from_reports')
      {
         szNewURL = "http://"+document.location.hostname+"/reports?type="+document.getElementById('type1').value
        window.location.href=szNewURL;                            
      }
      else if (from=='from_devices')
      {         
         var val=document.getElementById('type1').value;         
         if (val=="")
           szNewURL = "http://"+document.location.hostname+"/devices"
         else
           szNewURL = "http://"+document.location.hostname+"/devices?type="+document.getElementById('type1').value         
           window.location.href=szNewURL;                                
      }
     else if (from =='from_geofence')
     {
       var val=document.getElementById('type1').value;         
       if(val=="")
         szNewURL = "http://"+document.location.hostname+"/geofence"
       else if(val.split(' ')[0] == "device")  
         szNewURL = "http://"+document.location.hostname+"/geofence?type=device&id="+val.split(' ')[1]         
       else
        szNewURL = "http://"+document.location.hostname+"/geofence?type="+document.getElementById('type1').value         
       window.location.href=szNewURL;                                    
     }     
      else         
         new Ajax.Updater('to_update', '/home/show_devices?frm='+from, {asynchronous:true, evalScripts:true, parameters:'type='+escape($F('type1'))});javascript:getRecentReadings(true,document.getElementById('type1').value);
    }
}


