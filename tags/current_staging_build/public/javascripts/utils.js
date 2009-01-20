// String trim functions
String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}
String.prototype.ltrim = function() {
	return this.replace(/^\s+/,"");
}
String.prototype.rtrim = function() {
	return this.replace(/\s+$/,"");
}

// Function to display localized date/time
function displayLocalDT(dt) {
	return (new Date(dt).toString().split(" GMT")[0]);
}

// Function to display localized date
function displayLocalDate(dt) {
	return (new Date(dt).toDateString());
}


// Popup dynamically sized window
function popIt(url, name, props) {
	window.open(url, name, props);
}

function $(id) {
	return document.getElementById(id);
}