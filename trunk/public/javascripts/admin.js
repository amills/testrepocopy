var gmap;
var icon;
var position;

function load() {
	if (GBrowserIsCompatible()) {
		
		icon = new GIcon();
		icon.image = "/icons/ublip_marker.png";
		icon.shadow = "/images/ublip_marker_shadow.png";
		icon.iconSize = new GSize(23, 34);
		icon.iconAnchor = new GPoint(11, 34);
    icon.infoWindowAnchor = new GPoint(11, 34);
		
  	gmap = new GMap2(document.getElementById("map"));
	  gmap.addControl(new GLargeMapControl());
	  gmap.addControl(new GMapTypeControl());
	  gmap.setCenter(new GLatLng(37.0625, -95.677068), 3);
		gmap.enableScrollWheelZoom();
		
		// The fixed asset already has a location so display it
		if(position != undefined) {
			addMarker(new GLatLng(position[0], position[1]), icon);
			document.getElementById("address").value = position[2];
		}
		
		// User clicks on map to specify location
		GEvent.addListener(gmap, "click", function(overlay, point) {
			if(point) {
				var latlng = point.lat() + ',' + point.lng();
				getAddress(point);
			}
      });
			
	}
	document.getElementById("address").focus();
	document.getElementById("save").disabled = true;
}

function getAddress(point) {
	var geocoder = new GClientGeocoder();
	geocoder.getLocations(point, function(response) {
		if (!response || response.Status.code != 200) {
			// No valid address found so populate address with lat/lng
			addMarker(point);
		} else {
			var place = response.Placemark[0];
			document.getElementById("address").value = place.address;
			addMarker(point);
		}
	});
}

function geocode(address) {
	var geocoder = new GClientGeocoder();
	geocoder.getLatLng(
		address,
		function(point) {
    	if (!point) {
      	alert("We're sorry, this address cannot be located");
      } else {
				addMarker(point, icon);
			}
		});
}

function addMarker(point) {	
	gmap.clearOverlays();
	gmap.addOverlay(new GMarker(point, icon));
	gmap.panTo(point);
	document.getElementById("save").disabled = false;
	document.getElementById("latitude").value = point.lat();
	document.getElementById("longitude").value = point.lng();
	document.getElementById("address").value = document.getElementById("address").value;
}