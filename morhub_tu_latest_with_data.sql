-- MySQL dump 10.13  Distrib 8.0.46, for macos15 (arm64)
--
-- Host: 127.0.0.1    Database: morhub_tu
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `morhub_tu`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `morhub_tu` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `morhub_tu`;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `account_id` int unsigned NOT NULL AUTO_INCREMENT,
  `role` enum('patient','staff','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','active','disabled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `must_change_pw` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `photo` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uq_account_email` (`email`),
  KEY `idx_account_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,'admin','ผู้ดูแลระบบ MorHub TU','admin@morhubtu.co.th','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','02-999-0000','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL),(2,'staff','สมศักดิ์ ช่างเทค','tech@morhubtu.co.th','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','02-926-0001','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL),(3,'staff','อรุณี วงศ์ล้านนา','tech2@morhubtu.co.th','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','02-926-0002','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL),(4,'staff','ปรีชา สายสยาม','tech3@morhubtu.co.th','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','02-926-0003','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL),(6,'patient','สมชาย ใจดี','somchai@mail.com','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','081-234-5678','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL),(7,'patient','วิภา สุขสันต์','wipa@mail.com','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','089-111-2222','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL),(8,'patient','ประเสริฐ มั่นคง','prasert@mail.com','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','086-333-4444','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL),(9,'patient','นภัสสร แสงทอง','napat@mail.com','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','082-555-6666','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL),(10,'patient','อดิศร เจริญสุข','adisorn@mail.com','$2a$12$YnB8ykGZ/7udub6pYE/C5OqZd/m4NoPAKo6S5Q1.OBl2JmtfhupnC','091-777-8888','active',0,'2026-11-03 14:43:49','2026-11-03 14:43:49',NULL);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `appointment_id` int unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` int unsigned NOT NULL,
  `doctor_id` int unsigned NOT NULL,
  `appt_date` date NOT NULL,
  `appt_time` time NOT NULL,
  `symptom_note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','proposed','upcoming','seen','noshow','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `is_follow_up` tinyint(1) NOT NULL DEFAULT '0',
  `follow_up_of` int unsigned DEFAULT NULL,
  `confirmed_by` int unsigned DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `cancelled_by` enum('patient','hospital') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancel_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `nudged` tinyint(1) NOT NULL DEFAULT '0',
  `admin_gate` enum('request','reply','visit') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visited_at` datetime DEFAULT NULL,
  PRIMARY KEY (`appointment_id`),
  KEY `idx_appt_slot` (`doctor_id`,`appt_date`,`appt_time`,`status`),
  KEY `idx_appt_patient` (`patient_id`,`appt_date`),
  KEY `idx_appt_status` (`status`,`created_at`),
  KEY `idx_appt_followup` (`follow_up_of`),
  KEY `idx_appt_confirmed_by` (`confirmed_by`),
  CONSTRAINT `fk_appt_confirmed_by` FOREIGN KEY (`confirmed_by`) REFERENCES `staff` (`staff_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_appt_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_appt_followup` FOREIGN KEY (`follow_up_of`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_appt_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_appt_cancel` CHECK ((((`status` = _utf8mb4'cancelled') and (`cancelled_by` is not null)) or ((`status` <> _utf8mb4'cancelled') and (`cancelled_by` is null))))
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (5,6,11,'2026-11-04','09:00:00','ssss','cancelled',0,NULL,2,'2026-11-03 22:52:58','patient',NULL,'2026-11-03 23:21:33','2026-11-03 15:48:36','2026-11-03 16:21:33',0,NULL,NULL),(14,6,4,'2026-11-09','08:30:00','gg','seen',0,NULL,2,'2026-11-03 23:28:01',NULL,NULL,NULL,'2026-11-03 16:27:28','2026-11-03 16:34:15',0,NULL,'2026-11-03 23:33:14'),(16,6,2,'2026-11-04','10:00:00','kuay','seen',0,NULL,2,'2026-11-03 23:39:49',NULL,NULL,NULL,'2026-11-03 16:38:53','2026-11-03 16:40:33',0,NULL,'2026-11-03 23:40:01'),(18,6,15,'2026-11-04','14:00:00','hhh','seen',0,NULL,2,'2026-11-03 23:55:51',NULL,NULL,NULL,'2026-11-03 16:55:27','2026-11-03 16:56:34',0,NULL,'2026-11-03 23:56:01');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_appt_before_insert` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
  DECLARE v_cap   INT;
  DECLARE v_used  INT;
  DECLARE v_sched INT;

  -- 1) ต้องอยู่ในตารางออกตรวจของวันนั้น
  SELECT COUNT(*) INTO v_sched
    FROM doctor_schedules s
   WHERE s.doctor_id = NEW.doctor_id
     AND s.weekday   = DAYOFWEEK(NEW.appt_date) - 1      -- MySQL: 1=Sun -> 0
     AND NEW.appt_time >= s.start_time
     AND NEW.appt_time <  s.end_time;
  IF v_sched = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'แพทย์ไม่ได้ออกตรวจในวัน/เวลานี้';
  END IF;

  -- 2) แพทย์ลาวันนั้นหรือไม่
  IF EXISTS (SELECT 1 FROM doctor_leaves l
              WHERE l.doctor_id = NEW.doctor_id AND l.leave_date = NEW.appt_date) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'แพทย์งดออกตรวจในวันนี้';
  END IF;

  -- 3) ความจุของช่องเวลา
  SELECT slot_capacity INTO v_cap FROM doctors WHERE doctor_id = NEW.doctor_id;
  SELECT COUNT(*) INTO v_used
    FROM appointments a
   WHERE a.doctor_id = NEW.doctor_id
     AND a.appt_date = NEW.appt_date
     AND a.appt_time = NEW.appt_time
     AND a.status <> 'cancelled';
  IF v_used >= v_cap THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ช่องเวลานี้เต็มแล้ว';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `log_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `event_type` enum('pw_reset_request','pw_reset','pw_changed','act_start','act_end','account_approved','account_disabled','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_account_id` int unsigned DEFAULT NULL,
  `target_account_id` int unsigned DEFAULT NULL,
  `ref_log_id` bigint unsigned DEFAULT NULL,
  `reason` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration_sec` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_audit_type` (`event_type`,`created_at`),
  KEY `idx_audit_actor` (`actor_account_id`),
  KEY `idx_audit_target` (`target_account_id`),
  KEY `idx_audit_ref` (`ref_log_id`),
  CONSTRAINT `fk_audit_actor` FOREIGN KEY (`actor_account_id`) REFERENCES `accounts` (`account_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_audit_ref` FOREIGN KEY (`ref_log_id`) REFERENCES `audit_logs` (`log_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_audit_target` FOREIGN KEY (`target_account_id`) REFERENCES `accounts` (`account_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,'act_start',1,6,NULL,NULL,NULL,NULL,'2026-11-03 15:11:08');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `check_ins`
--

DROP TABLE IF EXISTS `check_ins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `check_ins` (
  `checkin_id` int unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` int unsigned NOT NULL,
  `patient_id` int unsigned NOT NULL,
  `qr_token_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `status` enum('issued','used','expired') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'issued',
  `checked_in_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`checkin_id`),
  UNIQUE KEY `uq_checkin_appointment` (`appointment_id`),
  UNIQUE KEY `uq_checkin_token_hash` (`qr_token_hash`),
  KEY `idx_checkin_patient` (`patient_id`),
  KEY `idx_checkin_expiry` (`status`,`expires_at`),
  CONSTRAINT `fk_checkin_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_checkin_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `check_ins`
--

LOCK TABLES `check_ins` WRITE;
/*!40000 ALTER TABLE `check_ins` DISABLE KEYS */;
INSERT INTO `check_ins` VALUES (1,1,6,'1d094dadab3622599a0fe462ecfb3a015aae9374c614f70d8ef70f0936591f9f','2026-11-04 22:21:43','issued',NULL,'2026-11-03 15:21:43');
/*!40000 ALTER TABLE `check_ins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `department_id` int unsigned NOT NULL AUTO_INCREMENT,
  `dept_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_name_th` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_name_en` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `uq_dept_code` (`dept_code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'ortho','ศัลยกรรมกระดูก','Orthopedics','bone'),(2,'med','อายุรกรรม','Internal Medicine','stethoscope'),(3,'surg','ศัลยกรรมทั่วไป','General Surgery','scissors'),(4,'ped','กุมารเวช','Pediatrics','smile'),(5,'ob','สูติ-นรีเวช','Obstetrics & Gynecology','heart'),(6,'ent','หู คอ จมูก','ENT','ear'),(7,'eye','จักษุ','Ophthalmology','eye'),(8,'psy','จิตเวช','Psychiatry','brain');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_leaves`
--

DROP TABLE IF EXISTS `doctor_leaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_leaves` (
  `leave_id` int unsigned NOT NULL AUTO_INCREMENT,
  `doctor_id` int unsigned NOT NULL,
  `leave_date` date NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`leave_id`),
  UNIQUE KEY `uq_leave` (`doctor_id`,`leave_date`),
  CONSTRAINT `fk_leave_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_leaves`
--

LOCK TABLES `doctor_leaves` WRITE;
/*!40000 ALTER TABLE `doctor_leaves` DISABLE KEYS */;
/*!40000 ALTER TABLE `doctor_leaves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_schedules`
--

DROP TABLE IF EXISTS `doctor_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_schedules` (
  `schedule_id` int unsigned NOT NULL AUTO_INCREMENT,
  `doctor_id` int unsigned NOT NULL,
  `weekday` tinyint unsigned NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  PRIMARY KEY (`schedule_id`),
  UNIQUE KEY `uq_schedule` (`doctor_id`,`weekday`,`start_time`),
  CONSTRAINT `fk_schedule_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_sched_time` CHECK ((`end_time` > `start_time`)),
  CONSTRAINT `chk_sched_weekday` CHECK ((`weekday` between 0 and 6))
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_schedules`
--

LOCK TABLES `doctor_schedules` WRITE;
/*!40000 ALTER TABLE `doctor_schedules` DISABLE KEYS */;
INSERT INTO `doctor_schedules` VALUES (1,1,1,'08:00:00','12:00:00'),(2,1,1,'13:00:00','16:00:00'),(3,1,2,'08:00:00','12:00:00'),(4,1,2,'13:00:00','16:00:00'),(5,1,4,'08:00:00','12:00:00'),(6,1,4,'13:00:00','16:00:00'),(7,2,1,'09:00:00','12:00:00'),(8,2,3,'09:00:00','12:00:00'),(9,2,5,'09:00:00','12:00:00'),(10,3,2,'13:00:00','17:00:00'),(11,3,3,'13:00:00','17:00:00'),(12,3,5,'13:00:00','17:00:00'),(13,4,1,'08:00:00','12:00:00'),(14,4,1,'13:00:00','16:00:00'),(15,4,2,'08:00:00','12:00:00'),(16,4,2,'13:00:00','16:00:00'),(17,4,3,'08:00:00','12:00:00'),(18,4,3,'13:00:00','16:00:00'),(19,4,4,'08:00:00','12:00:00'),(20,4,4,'13:00:00','16:00:00'),(21,4,5,'08:00:00','12:00:00'),(22,4,5,'13:00:00','16:00:00'),(23,5,2,'09:00:00','12:00:00'),(24,5,2,'13:00:00','15:00:00'),(25,5,4,'09:00:00','12:00:00'),(26,5,4,'13:00:00','15:00:00'),(27,6,1,'08:30:00','12:00:00'),(28,6,3,'08:30:00','12:00:00'),(29,6,5,'08:30:00','12:00:00'),(30,7,1,'08:00:00','12:00:00'),(31,7,2,'08:00:00','12:00:00'),(32,7,3,'08:00:00','12:00:00'),(33,7,4,'08:00:00','12:00:00'),(34,7,5,'08:00:00','12:00:00'),(35,8,1,'09:00:00','12:00:00'),(36,8,1,'13:00:00','15:30:00'),(37,8,3,'09:00:00','12:00:00'),(38,8,3,'13:00:00','15:30:00'),(39,8,5,'09:00:00','12:00:00'),(40,8,5,'13:00:00','15:30:00'),(41,9,2,'08:00:00','12:00:00'),(42,9,4,'08:00:00','12:00:00'),(43,9,6,'08:00:00','12:00:00'),(44,10,1,'13:00:00','16:00:00'),(45,10,4,'13:00:00','16:00:00'),(46,11,1,'08:00:00','12:00:00'),(47,11,2,'08:00:00','12:00:00'),(48,11,3,'08:00:00','12:00:00'),(49,11,4,'08:00:00','12:00:00'),(50,11,5,'08:00:00','12:00:00'),(51,12,2,'08:00:00','12:00:00'),(52,12,2,'13:00:00','16:00:00'),(53,12,4,'08:00:00','12:00:00'),(54,12,4,'13:00:00','16:00:00'),(55,12,6,'08:00:00','12:00:00'),(56,12,6,'13:00:00','16:00:00'),(57,13,3,'13:00:00','17:00:00'),(58,13,5,'13:00:00','17:00:00'),(59,14,1,'09:00:00','12:00:00'),(60,14,2,'09:00:00','12:00:00'),(61,14,4,'09:00:00','12:00:00'),(62,15,3,'10:00:00','15:00:00'),(63,15,5,'10:00:00','15:00:00'),(64,15,6,'10:00:00','15:00:00'),(65,16,1,'08:30:00','12:00:00'),(66,16,2,'08:30:00','12:00:00'),(67,16,3,'08:30:00','12:00:00');
/*!40000 ALTER TABLE `doctor_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctors` (
  `doctor_id` int unsigned NOT NULL AUTO_INCREMENT,
  `hospital_id` int unsigned NOT NULL,
  `department_id` int unsigned NOT NULL,
  `title` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'นพ.',
  `full_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `room` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `experience_years` tinyint unsigned DEFAULT NULL,
  `headline` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `education_th` text COLLATE utf8mb4_unicode_ci,
  `education_en` text COLLATE utf8mb4_unicode_ci,
  `slot_minutes` tinyint unsigned NOT NULL DEFAULT '30',
  `slot_capacity` tinyint unsigned NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `photo` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`doctor_id`),
  KEY `idx_doctor_hosp_dept` (`hospital_id`,`department_id`),
  KEY `idx_doctor_dept` (`department_id`),
  CONSTRAINT `fk_doctor_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_doctor_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_doctor_capacity` CHECK ((`slot_capacity` >= 1)),
  CONSTRAINT `chk_doctor_slot` CHECK ((`slot_minutes` in (10,15,20,30,60)))
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES (1,1,2,'นพ.','ธนา วงศ์สว่าง','อาคาร A ชั้น 3 ห้อง 304',12,NULL,NULL,NULL,30,3,1,'2026-11-03 14:43:49',NULL),(2,1,2,'พญ.','ปรียา ศรีสุข','อาคาร A ชั้น 3 ห้อง 306',9,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL),(3,1,1,'นพ.','กิตติ รัตนา','อาคาร B ชั้น 2 ห้อง 201',15,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL),(4,1,4,'พญ.','มัลลิกา ใจดี','อาคาร C ชั้น 1 ห้อง 105',7,NULL,NULL,NULL,30,4,1,'2026-11-03 14:43:49',NULL),(5,1,6,'นพ.','ศุภชัย พงษ์ไพร','อาคาร B ชั้น 3 ห้อง 310',10,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL),(6,1,5,'พญ.','วริษา แก้วมณี','อาคาร C ชั้น 2 ห้อง 214',11,NULL,NULL,NULL,30,3,1,'2026-11-03 14:43:49',NULL),(7,1,2,'นพ.','อนุชา ภูพิงค์','อาคารหลัก ชั้น 2 ห้อง 21',14,NULL,NULL,NULL,30,3,1,'2026-11-03 14:43:49',NULL),(8,1,4,'พญ.','สุนิสา ล้านนา','อาคารเด็ก ชั้น 1 ห้อง 3',8,NULL,NULL,NULL,30,3,1,'2026-11-03 14:43:49',NULL),(9,1,1,'นพ.','ชัยวัฒน์ ดอยสุเทพ','อาคารหลัก ชั้น 3 ห้อง 32',16,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL),(10,1,7,'พญ.','เพ็ญศรี นิมมาน','อาคารหลัก ชั้น 1 ห้อง 12',6,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL),(11,1,3,'นพ.','วีระพงษ์ อีสานดี','อาคาร 1 ชั้น 2 ห้อง 5',18,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL),(12,1,2,'พญ.','กนกวรรณ ขอนแก่น','อาคาร 1 ชั้น 1 ห้อง 8',10,NULL,NULL,NULL,30,3,1,'2026-11-03 14:43:49',NULL),(13,1,8,'นพ.','ธีรพล สายธาร','อาคาร 2 ชั้น 2 ห้อง 4',9,NULL,NULL,NULL,30,1,1,'2026-11-03 14:43:49',NULL),(14,1,5,'พญ.','ณิชา อันดามัน','อาคาร A ชั้น 2 ห้อง 9',12,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL),(15,1,6,'นพ.','ปกรณ์ ทะเลใส','อาคาร A ชั้น 3 ห้อง 14',11,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL),(16,1,7,'พญ.','รัชนีกร เกาะงาม','อาคาร B ชั้น 1 ห้อง 2',7,NULL,NULL,NULL,30,2,1,'2026-11-03 14:43:49',NULL);
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `history_clears`
--

DROP TABLE IF EXISTS `history_clears`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `history_clears` (
  `account_id` int unsigned NOT NULL,
  `kind` enum('notifications','appointments','tickets') COLLATE utf8mb4_unicode_ci NOT NULL,
  `cleared_at` datetime NOT NULL,
  PRIMARY KEY (`account_id`,`kind`),
  CONSTRAINT `fk_history_clears_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `history_clears`
--

LOCK TABLES `history_clears` WRITE;
/*!40000 ALTER TABLE `history_clears` DISABLE KEYS */;
INSERT INTO `history_clears` VALUES (6,'appointments','2026-11-03 23:56:46');
/*!40000 ALTER TABLE `history_clears` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hospitals`
--

DROP TABLE IF EXISTS `hospitals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hospitals` (
  `hospital_id` int unsigned NOT NULL AUTO_INCREMENT,
  `hospital_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `province` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opening_hours` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `photo` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`hospital_id`),
  UNIQUE KEY `uq_hospital_name` (`hospital_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hospitals`
--

LOCK TABLES `hospitals` WRITE;
/*!40000 ALTER TABLE `hospitals` DISABLE KEYS */;
INSERT INTO `hospitals` VALUES (1,'โรงพยาบาลธรรมศาสตร์เฉลิมพระเกียรติ','ปทุมธานี','95 หมู่ 7 ถ.พหลโยธิน ต.คลองหนึ่ง อ.คลองหลวง ปทุมธานี 12120','02-926-9999','ผู้ป่วยนอก จ-ศ 08:00-16:00','2026-11-03 14:43:49','2026-11-03 14:43:49',NULL);
/*!40000 ALTER TABLE `hospitals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medical_reports`
--

DROP TABLE IF EXISTS `medical_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medical_reports` (
  `report_id` int unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` int unsigned NOT NULL,
  `hospital_id` int unsigned NOT NULL,
  `appointment_id` int unsigned DEFAULT NULL,
  `doctor_id` int unsigned DEFAULT NULL,
  `visit_date` date NOT NULL,
  `diagnosis` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `advice` text COLLATE utf8mb4_unicode_ci,
  `next_appointment_id` int unsigned DEFAULT NULL,
  `is_closed` tinyint(1) NOT NULL DEFAULT '1',
  `seen_by_patient` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `admin_ok` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`report_id`),
  KEY `idx_report_patient` (`patient_id`,`visit_date`),
  KEY `idx_report_hospital` (`hospital_id`),
  KEY `idx_report_appt` (`appointment_id`),
  KEY `idx_report_doctor` (`doctor_id`),
  KEY `idx_report_next` (`next_appointment_id`),
  KEY `idx_report_creator` (`created_by`),
  CONSTRAINT `fk_report_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_report_creator` FOREIGN KEY (`created_by`) REFERENCES `staff` (`staff_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_report_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_report_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_report_next_appt` FOREIGN KEY (`next_appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_report_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_reports`
--

LOCK TABLES `medical_reports` WRITE;
/*!40000 ALTER TABLE `medical_reports` DISABLE KEYS */;
INSERT INTO `medical_reports` VALUES (6,6,1,14,4,'2026-11-03','aaaa',NULL,NULL,1,1,2,'2026-11-03 16:33:54',1),(7,6,1,16,2,'2026-11-03','hh',NULL,NULL,1,1,2,'2026-11-03 16:40:28',1),(8,6,1,18,15,'2026-11-03','Pukan gay',NULL,NULL,1,1,2,'2026-11-03 16:56:28',1);
/*!40000 ALTER TABLE `medical_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_reads`
--

DROP TABLE IF EXISTS `notification_reads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_reads` (
  `notification_id` int unsigned NOT NULL,
  `account_id` int unsigned NOT NULL,
  `read_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`,`account_id`),
  KEY `idx_read_account` (`account_id`),
  CONSTRAINT `fk_read_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_read_notif` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`notification_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_reads`
--

LOCK TABLES `notification_reads` WRITE;
/*!40000 ALTER TABLE `notification_reads` DISABLE KEYS */;
INSERT INTO `notification_reads` VALUES (71,6,'2026-11-03 16:28:30'),(81,2,'2026-11-03 16:33:34'),(99,2,'2026-11-03 16:56:15');
/*!40000 ALTER TABLE `notification_reads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int unsigned NOT NULL AUTO_INCREMENT,
  `target_type` enum('account','hospital','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_account_id` int unsigned DEFAULT NULL,
  `target_hospital_id` int unsigned DEFAULT NULL,
  `message` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_tab` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `appointment_id` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `idx_notif_account` (`target_account_id`,`created_at`),
  KEY `idx_notif_hosp` (`target_hospital_id`,`created_at`),
  KEY `idx_notif_type` (`target_type`,`created_at`),
  KEY `idx_notif_appt` (`appointment_id`),
  CONSTRAINT `fk_notif_account` FOREIGN KEY (`target_account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_notif_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_notif_hosp` FOREIGN KEY (`target_hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (20,'admin',NULL,NULL,'คำขอจองใหม่จาก สมชาย ใจดี · นพ.วีระพงษ์ อีสานดี 2026-11-04 09:00 · รอส่งต่อให้โรงพยาบาล','requests',5,'2026-11-03 15:48:36'),(21,'hospital',NULL,1,'คำขอจองใหม่จาก สมชาย ใจดี · นพ.วีระพงษ์ อีสานดี 2026-11-04 09:00','requests',5,'2026-11-03 15:49:54'),(22,'admin',NULL,NULL,'โรงพยาบาลยืนยันนัดกับ นพ.วีระพงษ์ อีสานดี 2026-11-04 09:00 · รอส่งให้ผู้ป่วย','requests',5,'2026-11-03 15:52:58'),(23,'account',6,NULL,'นัดกับ นพ.วีระพงษ์ อีสานดี 2026-11-04 09:00 ได้รับการยืนยันแล้ว','appts',5,'2026-11-03 15:54:24'),(24,'account',6,NULL,'เตือน: คุณมีนัดหมายในวันพรุ่งนี้ เวลา 09:00 น.','appts',5,'2026-11-03 15:59:54'),(53,'hospital',NULL,1,'สมชาย ใจดี ยกเลิกนัด 2026-11-04 09:00 · นพ.วีระพงษ์ อีสานดี','patients',5,'2026-11-03 16:21:33'),(68,'admin',NULL,NULL,'คำขอจองใหม่จาก สมชาย ใจดี · พญ.มัลลิกา ใจดี 2026-11-09 08:30 · รอส่งต่อให้โรงพยาบาล','requests',14,'2026-11-03 16:27:28'),(69,'hospital',NULL,1,'คำขอจองใหม่จาก สมชาย ใจดี · พญ.มัลลิกา ใจดี 2026-11-09 08:30','requests',14,'2026-11-03 16:27:51'),(70,'admin',NULL,NULL,'โรงพยาบาลยืนยันนัดกับ พญ.มัลลิกา ใจดี 2026-11-09 08:30 · รอส่งให้ผู้ป่วย','requests',14,'2026-11-03 16:28:01'),(71,'account',6,NULL,'นัดกับ พญ.มัลลิกา ใจดี 2026-11-09 08:30 ได้รับการยืนยันแล้ว','appts',14,'2026-11-03 16:28:07'),(80,'admin',NULL,NULL,'สมชาย ใจดี ยืนยันว่ามาตรวจแล้ว · พญ.มัลลิกา ใจดี 2026-11-09 08:30 · รอส่งต่อให้โรงพยาบาล','requests',14,'2026-11-03 16:33:14'),(81,'hospital',NULL,1,'สมชาย ใจดี มาตรวจแล้ว · พญ.มัลลิกา ใจดี 2026-11-09 08:30 · กรุณาส่งผลตรวจและยา','patients',14,'2026-11-03 16:33:28'),(82,'admin',NULL,NULL,'รายงานผลตรวจและยาใหม่ของ สมชาย ใจดี: aaaa · รออนุมัติ','requests',14,'2026-11-03 16:33:54'),(83,'account',6,NULL,'มีผลตรวจและยาใหม่: aaaa · การนัดครั้งนี้เสร็จสิ้นแล้ว','results',14,'2026-11-03 16:34:15'),(84,'admin',NULL,NULL,'คำขอจองใหม่จาก สมชาย ใจดี · พญ.ปรียา ศรีสุข 2026-11-04 10:00 · รอส่งต่อให้โรงพยาบาล','requests',16,'2026-11-03 16:38:53'),(85,'hospital',NULL,1,'คำขอจองใหม่จาก สมชาย ใจดี · พญ.ปรียา ศรีสุข 2026-11-04 10:00','requests',16,'2026-11-03 16:39:09'),(86,'admin',NULL,NULL,'โรงพยาบาลยืนยันนัดกับ พญ.ปรียา ศรีสุข 2026-11-04 10:00 · รอส่งให้ผู้ป่วย','requests',16,'2026-11-03 16:39:49'),(87,'account',6,NULL,'นัดกับ พญ.ปรียา ศรีสุข 2026-11-04 10:00 ได้รับการยืนยันแล้ว','appts',16,'2026-11-03 16:39:57'),(88,'admin',NULL,NULL,'สมชาย ใจดี ยืนยันว่ามาตรวจแล้ว · พญ.ปรียา ศรีสุข 2026-11-04 10:00 · รอส่งต่อให้โรงพยาบาล','requests',16,'2026-11-03 16:40:01'),(89,'hospital',NULL,1,'สมชาย ใจดี มาตรวจแล้ว · พญ.ปรียา ศรีสุข 2026-11-04 10:00 · กรุณาส่งผลตรวจและยา','patients',16,'2026-11-03 16:40:06'),(90,'admin',NULL,NULL,'รายงานผลตรวจและยาใหม่ของ สมชาย ใจดี: hh · รออนุมัติ','requests',16,'2026-11-03 16:40:28'),(91,'account',6,NULL,'มีผลตรวจและยาใหม่: hh · การนัดครั้งนี้เสร็จสิ้นแล้ว','results',16,'2026-11-03 16:40:33'),(94,'admin',NULL,NULL,'คำขอจองใหม่จาก สมชาย ใจดี · นพ.ปกรณ์ ทะเลใส 2026-11-04 14:00 · รอส่งต่อให้โรงพยาบาล','requests',18,'2026-11-03 16:55:27'),(95,'hospital',NULL,1,'คำขอจองใหม่จาก สมชาย ใจดี · นพ.ปกรณ์ ทะเลใส 2026-11-04 14:00','requests',18,'2026-11-03 16:55:46'),(96,'admin',NULL,NULL,'โรงพยาบาลยืนยันนัดกับ นพ.ปกรณ์ ทะเลใส 2026-11-04 14:00 · รอส่งให้ผู้ป่วย','requests',18,'2026-11-03 16:55:51'),(97,'account',6,NULL,'นัดกับ นพ.ปกรณ์ ทะเลใส 2026-11-04 14:00 ได้รับการยืนยันแล้ว','appts',18,'2026-11-03 16:55:56'),(98,'admin',NULL,NULL,'สมชาย ใจดี ยืนยันว่ามาตรวจแล้ว · นพ.ปกรณ์ ทะเลใส 2026-11-04 14:00 · รอส่งต่อให้โรงพยาบาล','requests',18,'2026-11-03 16:56:01'),(99,'hospital',NULL,1,'สมชาย ใจดี มาตรวจแล้ว · นพ.ปกรณ์ ทะเลใส 2026-11-04 14:00 · กรุณาส่งผลตรวจและยา','patients',18,'2026-11-03 16:56:08'),(100,'admin',NULL,NULL,'รายงานผลตรวจและยาใหม่ของ สมชาย ใจดี: Pukan gay · รออนุมัติ','requests',18,'2026-11-03 16:56:28'),(101,'account',6,NULL,'มีผลตรวจและยาใหม่: Pukan gay · การนัดครั้งนี้เสร็จสิ้นแล้ว','results',18,'2026-11-03 16:56:34');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patients` (
  `patient_id` int unsigned NOT NULL,
  `hn` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `allergies` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`patient_id`),
  UNIQUE KEY `uq_patient_hn` (`hn`),
  CONSTRAINT `fk_patient_account` FOREIGN KEY (`patient_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (6,'HN 100006','1990-05-14',NULL,'Penicillin'),(7,'HN 100007','1985-11-02',NULL,NULL),(8,'HN 100008','1972-03-21',NULL,NULL),(9,'HN 100009','1998-08-30',NULL,'อาหารทะเล'),(10,'HN 100010','1965-01-09',NULL,NULL);
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescriptions`
--

DROP TABLE IF EXISTS `prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescriptions` (
  `prescription_id` int unsigned NOT NULL AUTO_INCREMENT,
  `report_id` int unsigned NOT NULL,
  `drug_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dosage` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_days` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`prescription_id`),
  KEY `idx_rx_report` (`report_id`),
  CONSTRAINT `fk_rx_report` FOREIGN KEY (`report_id`) REFERENCES `medical_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescriptions`
--

LOCK TABLES `prescriptions` WRITE;
/*!40000 ALTER TABLE `prescriptions` DISABLE KEYS */;
INSERT INTO `prescriptions` VALUES (4,7,'asas','asasaas',NULL);
/*!40000 ALTER TABLE `prescriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `queues`
--

DROP TABLE IF EXISTS `queues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `queues` (
  `queue_id` int unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` int unsigned NOT NULL,
  `patient_id` int unsigned NOT NULL,
  `hospital_id` int unsigned NOT NULL,
  `department_id` int unsigned NOT NULL,
  `doctor_id` int unsigned NOT NULL,
  `queue_number` int unsigned NOT NULL,
  `queue_date` date NOT NULL,
  `status` enum('waiting','called','completed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `called_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`queue_id`),
  UNIQUE KEY `uq_queue_appointment` (`appointment_id`),
  UNIQUE KEY `uq_queue_number_per_hospital_day` (`hospital_id`,`queue_date`,`queue_number`),
  KEY `idx_queue_hospital_day_status` (`hospital_id`,`queue_date`,`status`),
  KEY `idx_queue_doctor_day` (`doctor_id`,`queue_date`),
  KEY `idx_queue_patient` (`patient_id`,`queue_date`),
  KEY `fk_queue_department` (`department_id`),
  CONSTRAINT `fk_queue_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_queue_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_queue_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_queue_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_queue_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `queues`
--

LOCK TABLES `queues` WRITE;
/*!40000 ALTER TABLE `queues` DISABLE KEYS */;
/*!40000 ALTER TABLE `queues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_files`
--

DROP TABLE IF EXISTS `report_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_files` (
  `file_id` int unsigned NOT NULL AUTO_INCREMENT,
  `report_id` int unsigned NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size_bytes` int unsigned DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_url` longtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`file_id`),
  KEY `idx_file_report` (`report_id`),
  CONSTRAINT `fk_file_report` FOREIGN KEY (`report_id`) REFERENCES `medical_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_files`
--

LOCK TABLES `report_files` WRITE;
/*!40000 ALTER TABLE `report_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reschedule_proposals`
--

DROP TABLE IF EXISTS `reschedule_proposals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reschedule_proposals` (
  `proposal_id` int unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` int unsigned NOT NULL,
  `new_doctor_id` int unsigned NOT NULL,
  `new_date` date NOT NULL,
  `new_time` time NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proposed_by` int unsigned DEFAULT NULL,
  `response` enum('waiting','accepted','declined','expired') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting',
  `proposed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `responded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`proposal_id`),
  KEY `idx_prop_appt` (`appointment_id`,`response`),
  KEY `idx_prop_slot` (`new_doctor_id`,`new_date`,`new_time`),
  KEY `idx_prop_staff` (`proposed_by`),
  CONSTRAINT `fk_prop_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prop_doctor` FOREIGN KEY (`new_doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_prop_staff` FOREIGN KEY (`proposed_by`) REFERENCES `staff` (`staff_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reschedule_proposals`
--

LOCK TABLES `reschedule_proposals` WRITE;
/*!40000 ALTER TABLE `reschedule_proposals` DISABLE KEYS */;
/*!40000 ALTER TABLE `reschedule_proposals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `staff_id` int unsigned NOT NULL,
  `hospital_id` int unsigned NOT NULL,
  `work_unit` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`staff_id`),
  KEY `idx_staff_hospital` (`hospital_id`),
  CONSTRAINT `fk_staff_account` FOREIGN KEY (`staff_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_staff_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` VALUES (2,1,'เวชระเบียน'),(3,1,'เวชระเบียน'),(4,1,'IT');
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_tickets`
--

DROP TABLE IF EXISTS `support_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_tickets` (
  `ticket_id` int unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` int unsigned DEFAULT NULL,
  `guest_name` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_contact` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `topic` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `appointment_id` int unsigned DEFAULT NULL,
  `hospital_id` int unsigned DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('open','resolved') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `resolution_note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolved_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`ticket_id`),
  KEY `idx_ticket_status` (`status`,`created_at`),
  KEY `idx_ticket_patient` (`patient_id`),
  KEY `idx_ticket_appt` (`appointment_id`),
  KEY `idx_ticket_hosp` (`hospital_id`),
  KEY `idx_ticket_resolver` (`resolved_by`),
  CONSTRAINT `fk_ticket_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ticket_hosp` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ticket_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ticket_resolver` FOREIGN KEY (`resolved_by`) REFERENCES `accounts` (`account_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_tickets`
--

LOCK TABLES `support_tickets` WRITE;
/*!40000 ALTER TABLE `support_tickets` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_slot_usage`
--

DROP TABLE IF EXISTS `v_slot_usage`;
/*!50001 DROP VIEW IF EXISTS `v_slot_usage`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_slot_usage` AS SELECT 
 1 AS `doctor_id`,
 1 AS `appt_date`,
 1 AS `appt_time`,
 1 AS `booked`,
 1 AS `capacity`,
 1 AS `seats_left`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'morhub_tu'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_confirm_appointment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_confirm_appointment`(
  IN p_appointment_id INT UNSIGNED,
  IN p_staff_id       INT UNSIGNED
)
BEGIN
  DECLARE v_status      VARCHAR(20);
  DECLARE v_appt_hosp   INT UNSIGNED;
  DECLARE v_staff_hosp  INT UNSIGNED;

  SELECT a.status, d.hospital_id
    INTO v_status, v_appt_hosp
    FROM appointments a
    JOIN doctors d ON d.doctor_id = a.doctor_id
   WHERE a.appointment_id = p_appointment_id;

  IF v_status IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ไม่พบนัดนี้';
  END IF;

  IF v_status <> 'pending' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ยืนยันได้เฉพาะนัดที่รอยืนยัน (pending)';
  END IF;

  SELECT hospital_id INTO v_staff_hosp
    FROM staff WHERE staff_id = p_staff_id;

  IF v_staff_hosp IS NULL OR v_staff_hosp <> v_appt_hosp THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'เจ้าหน้าที่ไม่ได้สังกัดโรงพยาบาลของนัดนี้';
  END IF;

  UPDATE appointments
     SET status       = 'upcoming',
         confirmed_by = p_staff_id,
         confirmed_at = NOW()
   WHERE appointment_id = p_appointment_id;

  SELECT a.appointment_id,
         acc.full_name                       AS patient,
         CONCAT(d.title, ' ', d.full_name)   AS doctor,
         a.appt_date, a.appt_time, a.status,
         st.full_name                        AS confirmed_by,
         a.confirmed_at
    FROM appointments a
    JOIN accounts acc ON acc.account_id = a.patient_id
    JOIN doctors  d   ON d.doctor_id    = a.doctor_id
    JOIN accounts st  ON st.account_id  = a.confirmed_by
   WHERE a.appointment_id = p_appointment_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `morhub_tu`
--

USE `morhub_tu`;

--
-- Final view structure for view `v_slot_usage`
--

/*!50001 DROP VIEW IF EXISTS `v_slot_usage`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_slot_usage` AS select `a`.`doctor_id` AS `doctor_id`,`a`.`appt_date` AS `appt_date`,`a`.`appt_time` AS `appt_time`,count(0) AS `booked`,`d`.`slot_capacity` AS `capacity`,(`d`.`slot_capacity` - count(0)) AS `seats_left` from (`appointments` `a` join `doctors` `d` on((`d`.`doctor_id` = `a`.`doctor_id`))) where (`a`.`status` <> 'cancelled') group by `a`.`doctor_id`,`a`.`appt_date`,`a`.`appt_time`,`d`.`slot_capacity` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-04  0:05:08
