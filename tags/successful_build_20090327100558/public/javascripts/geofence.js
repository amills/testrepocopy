var gmap;
var map;
var zoom = 3;
var icon;
var form;
var geofences = [];
var currSelectedDeviceId;
var currSelectedGeofenceId;
var gf_index;

function load() {
	if (GBrowserIsCompatible()) {
		map = document.getElementById("geofence_map");
	    gmap = new GMap2(map);
	    gmap.addControl(new GLargeMapControl());
	    gmap.addControl(new GMapTypeControl());
	    gmap.setCenter(new GLatLng(37.0625, -95.677068), zoom);
			gmap.enableScrollWheelZoom();
		
		icon = new GIcon();
		icon.image = "/icons/ublip_marker.png";
    	icon.shadow = "/images/ublip_marker_shadow.png";
    	icon.iconSize = new GSize(23, 34);
    	icon.iconAnchor = new GPoint(11, 34);
		
		// Form when editing or adding geofence
		form = document.getElementById("geofence_form");

		// Display the initial geofence, but not when adding a new one
		var action = document.location.href.split("/")[4];
		// Display the device location
		if(action == "add") {
			var point = new GLatLng(device.lat, device.lng);
			gmap.addOverlay(createMarker(point));
			gmap.openInfoWindowHtml(point, 'Last location for <strong>' + device.name + '</strong>');
			gmap.setCenter(point, 15);
			
      if(remove_listener == 'false'){ //added
			GEvent.addListener(gmap, "click", function(overlay, point) {
				var latlng = point.lat() + ',' + point.lng();
				document.getElementById('address').value = latlng;
          		geocode(latlng);
         	});}
		} else {
      if(remove_listener == 'false'){ //added
			GEvent.addListener(gmap, "click", function(overlay, point) {
				if(point) {
					gmap.clearOverlays();
					var latlng = point.lat() + ',' + point.lng();
					document.getElementById('address').value = latlng;
	        var r = document.getElementById("radius")[document.getElementById("radius").selectedIndex].value;
					drawGeofence(point, r);
					setZoomFromRadius(r);
					gmap.setZoom(zoom);
					gmap.panTo(point);
				}
			});}
			//displayGeofence(0);
            if (device_flag == 1){
                displayGeofence(gf_index);                
                currSelectedGeofenceId = geofences[0].id;
                var point = new GLatLng(device.lat, device.lng);
                gmap.addOverlay(createMarker(point));
            }
		}
	}
}

// Convert address to lat/lng
function geocode(address) {
	var geocoder = new GClientGeocoder();
	geocoder.getLatLng(
    	address,
		function(point) {
      		if (!point) {
        		alert("We're sorry, this address cannot be located");
      		} else {
				gmap.clearOverlays();
				// Draw the fence
				var r = document.getElementById("radius")[document.getElementById("radius").selectedIndex].value;
				drawGeofence(point, r);
				setZoomFromRadius(r);
        gmap.panTo(point, zoom);

				// Populate the bounds field
				form.bounds.value = point.lat() + ',' + point.lng() + ',' + r;            
				// Display the last location for the device                
                if (device !='false' ){
				   var device_location = new GLatLng(device.lat, device.lng);
				   gmap.addOverlay(createMarker(device_location));                
                }
      		}
    	}
  	);
}

function setZoomFromRadius(r) {
	if(parseInt(r) > 25) {
          zoom = 3;
  }
  else if(parseInt(r) > 5) {
          zoom = 7;
  }
  else if(parseInt(r) >= 1) {
          zoom = 10;
  }
  else {
          zoom = 14;
  }
}

// Draw geofence
function drawGeofence(p, r) {
	var cColor = "#0066FF";
	var cWidth = 5;
	var Cradius = r;   
 	var d2r = Math.PI/180; 
 	var r2d = 180/Math.PI; 
 	var Clat = (Cradius/3963)*r2d; 
	var Clng = Clat/Math.cos(p.lat()*d2r); 
	var Cpoints = []; 
	
	for (var i=0; i < 33; i++)
	{ 
    	var theta = Math.PI * (i/16); 
    	var CPlng = p.lng() + (Clng * Math.cos(theta)); 
    	var CPlat = p.lat() + (Clat * Math.sin(theta)); 
    	var P = new GLatLng(CPlat,CPlng);
    	Cpoints.push(P); 
  	}
  
  	gmap.addOverlay(new GPolyline(Cpoints,cColor,cWidth)); 
}

// Marker for geofence preview
function createMarker(p) {
	var marker = new GMarker(p, icon);
	return marker;
}

// Validation for geofence creation form
function validate() {
     form = document.getElementById('geofence_form');  
	if(form.name.value == '') {
		alert('Please specify a name for your geofence');
		return false;	
	}
	
	if(form.bounds.value == '') {
		alert('Please preview your geofence before saving');
		return false;
	}
	
	return true;
}


// Display a geofence when selected from the view list
function displayGeofence(index) {  
	var bounds = geofences[index].bounds.split(",");    
	var point = new GLatLng(parseFloat(bounds[0]), parseFloat(bounds[1]));    
	var radius = parseFloat(bounds[2]);
	gmap.clearOverlays();
	drawGeofence(point, radius);
	currSelectedGeofenceId = geofences[index].id;
	
	if(radius > 1)
		zoom = 9;
	else
		zoom = 14;
	
	gmap.setCenter(point, zoom);
}

function go(url) {
	document.location.href = url + '?geofence_id=' + currSelectedGeofenceId;
}

function enableDevice(id) {
	if(document.getElementById("all").value == '1' && document.getElementById("all").checked == true) {
		document.getElementById("device").disabled = true;
	} else {         
		document.getElementById("device").disabled = false;
	}
}
