DELIMITER ;;
USE ublip_prod;;

DROP TRIGGER IF EXISTS trig_readings_after_insert;;
CREATE TRIGGER trig_readings_after_insert AFTER INSERT ON readings FOR EACH ROW BEGIN
	
	DECLARE last_move_time DATETIME;
	DECLARE stop_begin_time DATETIME;
	DECLARE last_stop_duration INTEGER;
	DECLARE stop_count INTEGER;
	DECLARE current_stop_id INTEGER;
	DECLARE displacement FLOAT;
	
	SELECT COUNT(*) INTO stop_count FROM stop_events WHERE device_id=NEW.device_id;
	SELECT duration INTO last_stop_duration FROM stop_events WHERE device_id=NEW.device_id ORDER BY created_at DESC LIMIT 1;
	
	IF NEW.speed=0 AND (stop_count=0 OR last_stop_duration IS NOT NULL) THEN
		
		SELECT created_at INTO last_move_time FROM readings WHERE device_id=NEW.device_id AND created_at < NEW.created_at AND speed>0 order by created_at desc limit 1;
		
		IF TIMESTAMPDIFF(MINUTE, last_move_time, NEW.created_at) > 10 THEN
			SELECT created_at INTO stop_begin_time FROM readings WHERE device_id=NEW.device_id AND created_at > last_move_time AND speed=0 order by created_at asc limit 1; 
			INSERT INTO stop_events (device_id, latitude, longitude, created_at) VALUES (NEW.device_id, NEW.latitude, NEW.longitude, stop_begin_time);
		END IF;
		
	END IF;
	
	IF NEW.speed>0 AND stop_count>0 AND last_stop_duration IS NULL THEN
		SELECT id INTO current_stop_id FROM stop_events WHERE device_id=NEW.device_id AND duration IS NULL ORDER BY created_at DESC LIMIT 1;
		SELECT distance(NEW.latitude, NEW.longitude, latitude, longitude) INTO displacement FROM stop_events WHERE id=current_stop_id;
		IF displacement > 0.05 THEN 
			SELECT created_at INTO stop_begin_time FROM stop_events WHERE id=current_stop_id;
			UPDATE stop_events SET duration = TIMESTAMPDIFF(MINUTE, stop_begin_time, NEW.created_at) WHERE id=current_stop_id;
		END IF;
	END IF;
END;;

DROP FUNCTION IF EXISTS distance;;
CREATE FUNCTION distance (	
	lat1 FLOAT,
	lng1 FLOAT,
	lat2 FLOAT,
	lng2 FLOAT
) RETURNS FLOAT
DETERMINISTIC
COMMENT 'Calculate distance between two points in miles'
BEGIN
	RETURN (((acos(sin((lat1*pi()/180)) * sin((lat2*pi()/180)) + cos((lat1*pi()/180)) * cos((lat2*pi()/180)) 
   * cos(((lng1 - lng2)*pi()/180))))*180/pi())*60*1.1515);
END;;