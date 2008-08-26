// scrolling effect start
 var ieHoffset_extra=document.all? 15 : 0
 var dsocleft=document.all? iecompattest().scrollLeft : pageXOffset
 var dsoctop=document.all? iecompattest().scrollTop : pageYOffset
 var addtional_value=10;
 var distance_top;
 var temp_value1;
 var temp_value2;
 var myspeed = 0,cross_obj,arrow_obj,bName;
 var Hoffset,Voffset,HoffsetArrow,VoffsetArrow
 
 function initialiaze(){
 from_main? temp_value1 = 128 : temp_value1 = 160     
 from_main? temp_value2 = 112 : temp_value2 = 155     
 
 if (from_main)
     cross_obj=document.all? document.all.header_ddd : document.getElementById? document.getElementById("header_ddd") : document.header_ddd
 else
     cross_obj=document.all? document.all.map : document.getElementById? document.getElementById("map") : document.map
 
   arrow_obj = document.all? document.all.arrow_expand : document.getElementById? document.getElementById("arrow_expand") : document.arrow_expand

  bName = navigator.appName;  
  if (bName == "Microsoft Internet Explorer" ){       
     Hoffset =  (document.documentElement.clientWidth - ieHoffset_extra) - (document.documentElement.clientWidth - ieHoffset_extra)/2  + addtional_value
     Voffset =  document.documentElement.clientHeight - temp_value1    
     HoffsetArrow =  (document.documentElement.clientWidth - ieHoffset_extra) - (document.documentElement.clientWidth - ieHoffset_extra)/2 + 20
     VoffsetArrow = document.documentElement.clientHeight - temp_value1*3      
     from_main? distance_top = 112 : distance_top = 160
  }
  else{  
     Hoffset = ieNOTopera? iecompattest().clientWidth+ieHoffset_extra : window.innerWidth+ieHoffset_extra -  (document.documentElement.clientWidth - ieHoffset_extra)/2 - addtional_value
     Voffset=  ieNOTopera? iecompattest().clientHeight : window.innerHeight - temp_value2
     HoffsetArrow = ieNOTopera? iecompattest().clientWidth+ieHoffset_extra : window.innerWidth+ieHoffset_extra -  (document.documentElement.clientWidth - ieHoffset_extra)/2
     VoffsetArrow = ieNOTopera? iecompattest().clientHeight : window.innerHeight - temp_value2*3
     from_main? distance_top = 112 :  distance_top = 150
 }
}
 var thespeed=3 
 var ieNOTopera=document.all&&navigator.userAgent.indexOf("Opera")==-1
 
function iecompattest(){
    return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}

function positionit(){
	initialiaze();
    var dsocleft=document.all? iecompattest().scrollLeft : pageXOffset
    var dsoctop=document.all? iecompattest().scrollTop : pageYOffset
    var window_width=ieNOTopera? iecompattest().clientWidth+ieHoffset_extra : window.innerWidth+ieHoffset_extra
    var window_height=ieNOTopera? iecompattest().clientHeight : window.innerHeight 
    var divtop = 0;
    if (document.all||document.getElementById){ 
        cross_obj.style.left= fullScreenMap? 30 : parseInt(dsocleft)+parseInt(window_width)-Hoffset +"px"                
        arrow_obj.style.left = fullScreenMap? "1%" : parseInt(dsocleft)+parseInt(window_width)-HoffsetArrow +"px"    
       
	 //cross_obj.style.left = '51%';
	 //arrow_obj.style.left = '50%';
	 //cross_obj.style.position = '';
        var scrolltop = 0;
	 
        if(document.documentElement.scrollTop >= 0 && document.documentElement.scrollTop <= distance_top)
          scrolltop =  document.documentElement.scrollTop;
        else
         scrolltop = distance_top;
	 divtop = (dsoctop + window_height -Voffset -  scrolltop)*100;
	 divtop = divtop/window_height;
       
        cross_obj.style.top= fullScreenMap? "26%" : (dsoctop + window_height -Voffset -  scrolltop)+"px";
        arrow_obj.style.top= fullScreenMap? "50%" : (dsoctop+parseInt(window_height)-VoffsetArrow -  scrolltop)+"px"
    }
    else if (document.layers){
         cross_obj.left=dsocleft+window_width-Hoffset
         cross_obj.top=dsoctop+window_height-Voffset  
         arrow_obj.left=dsocleft+window_width-HoffsetArrow
         arrow_obj.top=dsoctop+window_height-VoffsetArrow          
    }
}

function scrollwindow(){
  window.scrollBy(0,myspeed)  
}




function initializeIT(){
  positionit()
    if (myspeed!=0){
    scrollwindow()
    }
}

if (document.all||document.getElementById||document.layers)
setInterval("positionit()",20)

// scrolling effect end

