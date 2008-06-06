DELIMITER ;;
USE ublip_prod;;

DROP TRIGGER IF EXISTS trig_stop_events_update;;
CREATE TRIGGER trig_stop_events_update BEFORE UPDATE ON stop_events FOR EACH ROW BEGIN
	IF OLD.duration IS NULL AND NEW.duration IS NOT NULL THEN
		INSERT INTO motion_events (device_id, latitude, longitude, created_at) VALUES (NEW.device_id, NEW.latitude, NEW.longitude, TIMESTAMPADD(MINUTE, NEW.duration, NEW.created_at) );
	END IF;
END;;