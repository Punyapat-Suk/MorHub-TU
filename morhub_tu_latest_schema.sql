-- =====================================================================
--  MorHub TU — Database schema (structure only, no data)
--  MySQL 8.0.16+  ·  InnoDB  ·  utf8mb4
--  Generated from the live database on 2026-11-04
--  Includes: admin approval flow, visit confirmation, QR check-in & queue, clear history
--
--  WARNING: running this file drops and recreates every table in morhub_tu.
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS morhub_tu
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE morhub_tu;

DROP VIEW IF EXISTS `v_slot_usage`;
DROP TABLE IF EXISTS `support_tickets`;
DROP TABLE IF EXISTS `reschedule_proposals`;
DROP TABLE IF EXISTS `report_files`;
DROP TABLE IF EXISTS `queues`;
DROP TABLE IF EXISTS `prescriptions`;
DROP TABLE IF EXISTS `notification_reads`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `medical_reports`;
DROP TABLE IF EXISTS `history_clears`;
DROP TABLE IF EXISTS `doctor_schedules`;
DROP TABLE IF EXISTS `doctor_leaves`;
DROP TABLE IF EXISTS `check_ins`;
DROP TABLE IF EXISTS `audit_logs`;
DROP TABLE IF EXISTS `appointments`;
DROP TABLE IF EXISTS `patients`;
DROP TABLE IF EXISTS `doctors`;
DROP TABLE IF EXISTS `departments`;
DROP TABLE IF EXISTS `staff`;
DROP TABLE IF EXISTS `hospitals`;
DROP TABLE IF EXISTS `accounts`;

-- ---------------------------------------------------------------------
-- 1) accounts
-- ---------------------------------------------------------------------
CREATE TABLE `accounts` (
  `account_id` int unsigned NOT NULL AUTO_INCREMENT,
  `role` enum('patient','staff','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','active','disabled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `must_change_pw` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `photo` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uq_account_email` (`email`),
  KEY `idx_account_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2) hospitals
-- ---------------------------------------------------------------------
CREATE TABLE `hospitals` (
  `hospital_id` int unsigned NOT NULL AUTO_INCREMENT,
  `hospital_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `province` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opening_hours` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `photo` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`hospital_id`),
  UNIQUE KEY `uq_hospital_name` (`hospital_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3) staff
-- ---------------------------------------------------------------------
CREATE TABLE `staff` (
  `staff_id` int unsigned NOT NULL,
  `hospital_id` int unsigned NOT NULL,
  `work_unit` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`staff_id`),
  KEY `idx_staff_hospital` (`hospital_id`),
  CONSTRAINT `fk_staff_account` FOREIGN KEY (`staff_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_staff_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4) departments
-- ---------------------------------------------------------------------
CREATE TABLE `departments` (
  `department_id` int unsigned NOT NULL AUTO_INCREMENT,
  `dept_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_name_th` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dept_name_en` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `uq_dept_code` (`dept_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5) doctors
-- ---------------------------------------------------------------------
CREATE TABLE `doctors` (
  `doctor_id` int unsigned NOT NULL AUTO_INCREMENT,
  `hospital_id` int unsigned NOT NULL,
  `department_id` int unsigned NOT NULL,
  `title` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'นพ.',
  `full_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `room` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `experience_years` tinyint unsigned DEFAULT NULL,
  `headline` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `education_th` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `education_en` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `slot_minutes` tinyint unsigned NOT NULL DEFAULT '30',
  `slot_capacity` tinyint unsigned NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `photo` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`doctor_id`),
  KEY `idx_doctor_hosp_dept` (`hospital_id`,`department_id`),
  KEY `idx_doctor_dept` (`department_id`),
  CONSTRAINT `fk_doctor_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_doctor_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_doctor_capacity` CHECK ((`slot_capacity` >= 1)),
  CONSTRAINT `chk_doctor_slot` CHECK ((`slot_minutes` in (10,15,20,30,60)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6) patients
-- ---------------------------------------------------------------------
CREATE TABLE `patients` (
  `patient_id` int unsigned NOT NULL,
  `hn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `allergies` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`patient_id`),
  UNIQUE KEY `uq_patient_hn` (`hn`),
  CONSTRAINT `fk_patient_account` FOREIGN KEY (`patient_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 7) appointments
-- ---------------------------------------------------------------------
CREATE TABLE `appointments` (
  `appointment_id` int unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` int unsigned NOT NULL,
  `doctor_id` int unsigned NOT NULL,
  `appt_date` date NOT NULL,
  `appt_time` time NOT NULL,
  `symptom_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','proposed','upcoming','seen','noshow','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `is_follow_up` tinyint(1) NOT NULL DEFAULT '0',
  `follow_up_of` int unsigned DEFAULT NULL,
  `confirmed_by` int unsigned DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `cancelled_by` enum('patient','hospital') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `nudged` tinyint(1) NOT NULL DEFAULT '0',
  `admin_gate` enum('request','reply','visit') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 8) audit_logs
-- ---------------------------------------------------------------------
CREATE TABLE `audit_logs` (
  `log_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `event_type` enum('pw_reset_request','pw_reset','pw_changed','act_start','act_end','account_approved','account_disabled','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_account_id` int unsigned DEFAULT NULL,
  `target_account_id` int unsigned DEFAULT NULL,
  `ref_log_id` bigint unsigned DEFAULT NULL,
  `reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 9) check_ins
-- ---------------------------------------------------------------------
CREATE TABLE `check_ins` (
  `checkin_id` int unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` int unsigned NOT NULL,
  `patient_id` int unsigned NOT NULL,
  `qr_token_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `status` enum('issued','used','expired') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'issued',
  `checked_in_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`checkin_id`),
  UNIQUE KEY `uq_checkin_appointment` (`appointment_id`),
  UNIQUE KEY `uq_checkin_token_hash` (`qr_token_hash`),
  KEY `idx_checkin_patient` (`patient_id`),
  KEY `idx_checkin_expiry` (`status`,`expires_at`),
  CONSTRAINT `fk_checkin_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_checkin_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 10) doctor_leaves
-- ---------------------------------------------------------------------
CREATE TABLE `doctor_leaves` (
  `leave_id` int unsigned NOT NULL AUTO_INCREMENT,
  `doctor_id` int unsigned NOT NULL,
  `leave_date` date NOT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`leave_id`),
  UNIQUE KEY `uq_leave` (`doctor_id`,`leave_date`),
  CONSTRAINT `fk_leave_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 11) doctor_schedules
-- ---------------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 12) history_clears
-- ---------------------------------------------------------------------
CREATE TABLE `history_clears` (
  `account_id` int unsigned NOT NULL,
  `kind` enum('notifications','appointments','tickets') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cleared_at` datetime NOT NULL,
  PRIMARY KEY (`account_id`,`kind`),
  CONSTRAINT `fk_history_clears_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 13) medical_reports
-- ---------------------------------------------------------------------
CREATE TABLE `medical_reports` (
  `report_id` int unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` int unsigned NOT NULL,
  `hospital_id` int unsigned NOT NULL,
  `appointment_id` int unsigned DEFAULT NULL,
  `doctor_id` int unsigned DEFAULT NULL,
  `visit_date` date NOT NULL,
  `diagnosis` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `advice` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 14) notifications
-- ---------------------------------------------------------------------
CREATE TABLE `notifications` (
  `notification_id` int unsigned NOT NULL AUTO_INCREMENT,
  `target_type` enum('account','hospital','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_account_id` int unsigned DEFAULT NULL,
  `target_hospital_id` int unsigned DEFAULT NULL,
  `message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_tab` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 15) notification_reads
-- ---------------------------------------------------------------------
CREATE TABLE `notification_reads` (
  `notification_id` int unsigned NOT NULL,
  `account_id` int unsigned NOT NULL,
  `read_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`,`account_id`),
  KEY `idx_read_account` (`account_id`),
  CONSTRAINT `fk_read_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_read_notif` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`notification_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 16) prescriptions
-- ---------------------------------------------------------------------
CREATE TABLE `prescriptions` (
  `prescription_id` int unsigned NOT NULL AUTO_INCREMENT,
  `report_id` int unsigned NOT NULL,
  `drug_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dosage` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_days` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`prescription_id`),
  KEY `idx_rx_report` (`report_id`),
  CONSTRAINT `fk_rx_report` FOREIGN KEY (`report_id`) REFERENCES `medical_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 17) queues
-- ---------------------------------------------------------------------
CREATE TABLE `queues` (
  `queue_id` int unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` int unsigned NOT NULL,
  `patient_id` int unsigned NOT NULL,
  `hospital_id` int unsigned NOT NULL,
  `department_id` int unsigned NOT NULL,
  `doctor_id` int unsigned NOT NULL,
  `queue_number` int unsigned NOT NULL,
  `queue_date` date NOT NULL,
  `status` enum('waiting','called','completed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting',
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

-- ---------------------------------------------------------------------
-- 18) report_files
-- ---------------------------------------------------------------------
CREATE TABLE `report_files` (
  `file_id` int unsigned NOT NULL AUTO_INCREMENT,
  `report_id` int unsigned NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size_bytes` int unsigned DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_url` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`file_id`),
  KEY `idx_file_report` (`report_id`),
  CONSTRAINT `fk_file_report` FOREIGN KEY (`report_id`) REFERENCES `medical_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 19) reschedule_proposals
-- ---------------------------------------------------------------------
CREATE TABLE `reschedule_proposals` (
  `proposal_id` int unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` int unsigned NOT NULL,
  `new_doctor_id` int unsigned NOT NULL,
  `new_date` date NOT NULL,
  `new_time` time NOT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proposed_by` int unsigned DEFAULT NULL,
  `response` enum('waiting','accepted','declined','expired') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting',
  `proposed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `responded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`proposal_id`),
  KEY `idx_prop_appt` (`appointment_id`,`response`),
  KEY `idx_prop_slot` (`new_doctor_id`,`new_date`,`new_time`),
  KEY `idx_prop_staff` (`proposed_by`),
  CONSTRAINT `fk_prop_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prop_doctor` FOREIGN KEY (`new_doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_prop_staff` FOREIGN KEY (`proposed_by`) REFERENCES `staff` (`staff_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 20) support_tickets
-- ---------------------------------------------------------------------
CREATE TABLE `support_tickets` (
  `ticket_id` int unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` int unsigned DEFAULT NULL,
  `guest_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_contact` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `topic` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `appointment_id` int unsigned DEFAULT NULL,
  `hospital_id` int unsigned DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('open','resolved') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `resolution_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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

-- ---------------------------------------------------------------------
-- View: v_slot_usage
-- ---------------------------------------------------------------------
CREATE VIEW `v_slot_usage` AS select `a`.`doctor_id` AS `doctor_id`,`a`.`appt_date` AS `appt_date`,`a`.`appt_time` AS `appt_time`,count(0) AS `booked`,`d`.`slot_capacity` AS `capacity`,(`d`.`slot_capacity` - count(0)) AS `seats_left` from (`appointments` `a` join `doctors` `d` on((`d`.`doctor_id` = `a`.`doctor_id`))) where (`a`.`status` <> 'cancelled') group by `a`.`doctor_id`,`a`.`appt_date`,`a`.`appt_time`,`d`.`slot_capacity`;

-- =====================================================================
--  Triggers and stored procedures
-- =====================================================================
DROP TRIGGER IF EXISTS `trg_appt_before_insert`;
DROP PROCEDURE IF EXISTS `sp_confirm_appointment`;

DELIMITER $$

CREATE TRIGGER `trg_appt_before_insert` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
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
END$$

CREATE PROCEDURE `sp_confirm_appointment`(
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
END$$

DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
