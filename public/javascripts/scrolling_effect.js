// scrolling effect start
if ((screen.width<=1024) && (screen.height <=768))
{
    var Hoffset=1020
    var Voffset=550
    distance_top = 240    
}
else
{
     var Hoffset=1150
    var Voffset=635
    distance_top = 150
}
var thespeed=3 

var ieNOTopera=document.all&&navigator.userAgent.indexOf("Opera")==-1
var myspeed=0

var ieHoffset_extra=document.all? 15 : 0
var cross_obj=document.all? document.all.map : document.getElementById? document.getElementById("map") : document.map

function iecompattest(){
    return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}

function positionit(){
    var dsocleft=document.all? iecompattest().scrollLeft : pageXOffset
    var dsoctop=document.all? iecompattest().scrollTop : pageYOffset
    var window_width=ieNOTopera? iecompattest().clientWidth+ieHoffset_extra : window.innerWidth+ieHoffset_extra
    var window_height=ieNOTopera? iecompattest().clientHeight : window.innerHeight 
    if (document.all||document.getElementById){ 
        cross_obj.style.left=parseInt(dsocleft)+parseInt(window_width)-Hoffset +"px"
        var scrolltop = 0;
        if(document.documentElement.scrollTop >= 0 && document.documentElement.scrollTop <= distance_top)
          scrolltop =  document.documentElement.scrollTop;
        else
         scrolltop = distance_top;
        cross_obj.style.top=(dsoctop+parseInt(window_height)-Voffset -  scrolltop)+"px"
    }
    else if (document.layers){
         cross_obj.left=dsocleft+window_width-Hoffset
         cross_obj.top=dsoctop+window_height-Voffset          
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
