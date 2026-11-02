-- MorHub TU additive migration for QR Check-in and Queue Management.
-- Run this against the EXISTING morhub_tu database after taking a backup.
-- This file does NOT drop or recreate any existing table/database.
USE morhub_tu;

CREATE TABLE IF NOT EXISTS check_ins (
  checkin_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  appointment_id   INT UNSIGNED NOT NULL,
  patient_id       INT UNSIGNED NOT NULL,
  qr_token_hash    CHAR(64) NOT NULL,
  expires_at       DATETIME NOT NULL,
  status           ENUM('issued','used','expired') NOT NULL DEFAULT 'issued',
  checked_in_at    DATETIME NULL,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (checkin_id),
  UNIQUE KEY uq_checkin_appointment (appointment_id),
  UNIQUE KEY uq_checkin_token_hash (qr_token_hash),
  KEY idx_checkin_patient (patient_id),
  KEY idx_checkin_expiry (status, expires_at),
  CONSTRAINT fk_checkin_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments (appointment_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_checkin_patient FOREIGN KEY (patient_id)
    REFERENCES patients (patient_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS queues (
  queue_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  appointment_id   INT UNSIGNED NOT NULL,
  patient_id       INT UNSIGNED NOT NULL,
  hospital_id      INT UNSIGNED NOT NULL,
  department_id    INT UNSIGNED NOT NULL,
  doctor_id        INT UNSIGNED NOT NULL,
  queue_number     INT UNSIGNED NOT NULL,
  queue_date       DATE NOT NULL,
  status           ENUM('waiting','called','completed','cancelled') NOT NULL DEFAULT 'waiting',
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  called_at        DATETIME NULL,
  completed_at     DATETIME NULL,
  PRIMARY KEY (queue_id),
  UNIQUE KEY uq_queue_appointment (appointment_id),
  UNIQUE KEY uq_queue_number_per_hospital_day (hospital_id, queue_date, queue_number),
  KEY idx_queue_hospital_day_status (hospital_id, queue_date, status),
  KEY idx_queue_doctor_day (doctor_id, queue_date),
  KEY idx_queue_patient (patient_id, queue_date),
  CONSTRAINT fk_queue_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments (appointment_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_queue_patient FOREIGN KEY (patient_id)
    REFERENCES patients (patient_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_queue_hospital FOREIGN KEY (hospital_id)
    REFERENCES hospitals (hospital_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_queue_department FOREIGN KEY (department_id)
    REFERENCES departments (department_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_queue_doctor FOREIGN KEY (doctor_id)
    REFERENCES doctors (doctor_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
