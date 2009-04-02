-- MySQL dump 10.11
--
-- Host: localhost    Database: simcom_prod
-- ------------------------------------------------------
-- Server version	5.0.45-Debian_1ubuntu3.3-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
CREATE TABLE `devices` (
  `id` int(11) NOT NULL auto_increment,
  `imei` varchar(30) default NULL,
  `msisdn` varchar(20) default NULL,
  `ip_address` varchar(16) default NULL,
  `port` int(11) default NULL,
  `powerState` varchar(10) default NULL,
  `iccid` varchar(25) default NULL,
  `hardwareVersion` varchar(50) default NULL,
  `softwareVersion` varchar(50) default NULL,
  `rssi` varchar(10) default NULL,
  `event_type` varchar(30) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;


DELIMITER ;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;

--
-- Table structure for table `devices_config`
--

DROP TABLE IF EXISTS `devices_config`;
CREATE TABLE `devices_config` (
  `id` int(11) NOT NULL auto_increment,
  `device_id` varchar(25) default NULL,
  `nickName` varchar(25) default NULL,
  `password` varchar(25) default NULL,
  `server1Ip` varchar(25) default NULL,
  `server1Port` int(11) default NULL,
  `server2Ip` varchar(25) default NULL,
  `server2Port` int(11) default NULL,
  `smsc1` varchar(50) default NULL,
  `smsc2` varchar(50) default NULL,
  `geofence0Tag` varchar(10) default NULL,
  `geofence0Longitude` float default NULL,
  `geofence0Latitude` float default NULL,
  `geofence0Radius` int(11) default NULL,
  `geofence0ChckInterval` int(11) default NULL,
  `geofence1Tag` varchar(10) default NULL,
  `geofence1Longitude` float default NULL,
  `geofence1Latitude` float default NULL,
  `geofence1Radius` int(11) default NULL,
  `geofence1ChckInterval` int(11) default NULL,
  `geofence2Tag` varchar(10) default NULL,
  `geofence2Longitude` float default NULL,
  `geofence2Latitude` float default NULL,
  `geofence2Radius` int(11) default NULL,
  `geofence2ChckInterval` int(11) default NULL,
  `geofence3Tag` varchar(10) default NULL,
  `geofence3Longitude` float default NULL,
  `geofence3Latitude` float default NULL,
  `geofence3Radius` int(11) default NULL,
  `geofence3ChckInterval` int(11) default NULL,
  `geofence4Tag` varchar(10) default NULL,
  `geofence4Longitude` float default NULL,
  `geofence4Latitude` float default NULL,
  `geofence4Radius` int(11) default NULL,
  `geofence4ChckInterval` int(11) default NULL,
  `created_at` datetime default NULL,
  `event_type` varchar(30) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `raw_payload` varchar(1000) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

--
-- Table structure for table `outbound`
--

DROP TABLE IF EXISTS `outbound`;
CREATE TABLE `outbound` (
  `id` int(11) NOT NULL auto_increment,
  `device_id` varchar(25) default NULL,
  `imei` varchar(30) default NULL,
  `command` varchar(100) default NULL,
  `response` varchar(100) default NULL,
  `status` varchar(50) default 'Processing',
  `start_date_time` datetime default NULL,
  `end_date_time` datetime default NULL,
  `transaction_id` varchar(25) default NULL,
  `generated_command` varchar(250) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=641 DEFAULT CHARSET=latin1;

--
-- Table structure for table `readings`
--

DROP TABLE IF EXISTS `readings`;
CREATE TABLE `readings` (
  `id` int(11) NOT NULL auto_increment,
  `device_id` varchar(25) default NULL,
  `count` int(11) default NULL,
  `zoneId` varchar(5) default NULL,
  `zoneAlert` int(11) default NULL,
  `fix` int(11) default NULL,
  `numberOfSatelites` int(11) default NULL,
  `speed` float default NULL,
  `heading` int(11) default NULL,
  `latitude` float default NULL,
  `longitude` float default NULL,
  `altitude` float default NULL,
  `event_type` varchar(30) default NULL,
  `created_at` datetime default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `raw_payload` varchar(500) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2801 DEFAULT CHARSET=latin1;


DELIMITER ;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-02-01 17:49:02