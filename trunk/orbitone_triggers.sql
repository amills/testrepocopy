DELIMITER ;;
use orbitone;;

drop trigger IF EXISTS trig_readings_before_insert;;
CREATE TRIGGER trig_readings_before_insert BEFORE INSERT ON readings FOR EACH ROW BEGIN
	DECLARE deviceID int(11);
	SELECT id INTO deviceID FROM ublip_prod.devices where imei=NEW.esn;

	IF !(NEW.latitude=0 AND NEW.longitude=0) THEN
		INSERT INTO ublip_prod.readings (device_id, latitude,longitude,created_at, battery_status, message_count, in_motion, subsequent_message) VALUES (deviceID, NEW.latitude, NEW.longitude, NEW.gps_timestamp, NEW.battery_status, NEW.message_count, NEW.in_motion, NEW.subsequent_message);
	END IF;
END;;