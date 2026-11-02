-- =====================================================================
--  MorHub TU — ระบบจองนัดพบแพทย์ โรงพยาบาลธรรมศาสตร์เฉลิมพระเกียรติ
--  Database schema for MySQL 8.0.16+  (InnoDB, utf8mb4)
--  CSS326 Database Programming Laboratory — Final Project
-- =====================================================================

DROP DATABASE IF EXISTS morhub_tu;
CREATE DATABASE morhub_tu
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE morhub_tu;

-- ---------------------------------------------------------------------
-- 1) hospitals : ข้อมูลโรงพยาบาลในระบบ
-- ---------------------------------------------------------------------
CREATE TABLE hospitals (
  hospital_id     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  hospital_name   VARCHAR(150)  NOT NULL,
  province        VARCHAR(80)   NOT NULL,
  address         VARCHAR(255)  NULL,
  phone           VARCHAR(20)   NULL,
  opening_hours   VARCHAR(150)  NULL,          -- เช่น 'ผู้ป่วยนอก จ-ศ 08:00-16:00'
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (hospital_id),
  UNIQUE KEY uq_hospital_name (hospital_name)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2) departments : แผนกการรักษา (อายุรกรรม, กุมารเวช, จักษุ ...)
-- ---------------------------------------------------------------------
CREATE TABLE departments (
  department_id   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  dept_code       VARCHAR(10)   NOT NULL,      -- 'med','ortho','ped' ...
  dept_name_th    VARCHAR(100)  NOT NULL,
  dept_name_en    VARCHAR(100)  NULL,
  icon            VARCHAR(30)   NULL,
  PRIMARY KEY (department_id),
  UNIQUE KEY uq_dept_code (dept_code)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3) accounts : บัญชีผู้ใช้ทุกบทบาท (patient / staff / admin) ใช้ login
-- ---------------------------------------------------------------------
CREATE TABLE accounts (
  account_id      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  role            ENUM('patient','staff','admin') NOT NULL,
  full_name       VARCHAR(120)  NOT NULL,
  email           VARCHAR(120)  NOT NULL,
  password_hash   VARCHAR(255)  NOT NULL,      -- เก็บ hash (bcrypt) ห้ามเก็บรหัสผ่านจริง
  phone           VARCHAR(20)   NULL,
  status          ENUM('pending','active','disabled') NOT NULL DEFAULT 'active',
  must_change_pw  BOOLEAN       NOT NULL DEFAULT FALSE,  -- หลังแอดมินรีเซ็ตรหัสผ่าน
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (account_id),
  UNIQUE KEY uq_account_email (email),
  KEY idx_account_role (role)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4) patients : ข้อมูลเฉพาะคนไข้ (1:1 กับ accounts ที่ role='patient')
-- ---------------------------------------------------------------------
CREATE TABLE patients (
  patient_id      INT UNSIGNED  NOT NULL,      -- = accounts.account_id
  hn              VARCHAR(20)   NULL,          -- Hospital Number
  date_of_birth   DATE          NULL,
  gender          ENUM('male','female','other') NULL,
  allergies       VARCHAR(255)  NULL,          -- เช่น 'Penicillin', 'อาหารทะเล'
  PRIMARY KEY (patient_id),
  UNIQUE KEY uq_patient_hn (hn),
  CONSTRAINT fk_patient_account
    FOREIGN KEY (patient_id) REFERENCES accounts (account_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5) staff : เจ้าหน้าที่ รพ. (1:1 กับ accounts ที่ role='staff')
-- ---------------------------------------------------------------------
CREATE TABLE staff (
  staff_id        INT UNSIGNED  NOT NULL,      -- = accounts.account_id
  hospital_id     INT UNSIGNED  NOT NULL,
  work_unit       VARCHAR(80)   NULL,          -- 'เวชระเบียน', 'IT', 'คลินิกเด็ก'
  PRIMARY KEY (staff_id),
  KEY idx_staff_hospital (hospital_id),
  CONSTRAINT fk_staff_account
    FOREIGN KEY (staff_id) REFERENCES accounts (account_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_staff_hospital
    FOREIGN KEY (hospital_id) REFERENCES hospitals (hospital_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6) doctors : แพทย์ (สังกัดโรงพยาบาล + แผนก)
--    slot_capacity = จำนวนคนไข้ที่รับได้ต่อช่อง 30 นาที
-- ---------------------------------------------------------------------
CREATE TABLE doctors (
  doctor_id         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  hospital_id       INT UNSIGNED     NOT NULL,
  department_id     INT UNSIGNED     NOT NULL,
  title             VARCHAR(20)      NOT NULL DEFAULT 'นพ.',   -- นพ. / พญ.
  full_name         VARCHAR(120)     NOT NULL,
  room              VARCHAR(100)     NULL,                     -- 'อาคาร A ชั้น 3 ห้อง 304'
  experience_years  TINYINT UNSIGNED NULL,
  slot_minutes      TINYINT UNSIGNED NOT NULL DEFAULT 30,
  slot_capacity     TINYINT UNSIGNED NOT NULL DEFAULT 1,
  is_active         BOOLEAN          NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (doctor_id),
  KEY idx_doctor_hosp_dept (hospital_id, department_id),
  KEY idx_doctor_dept (department_id),
  CONSTRAINT fk_doctor_hospital
    FOREIGN KEY (hospital_id) REFERENCES hospitals (hospital_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_doctor_department
    FOREIGN KEY (department_id) REFERENCES departments (department_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_doctor_capacity CHECK (slot_capacity >= 1),
  CONSTRAINT chk_doctor_slot     CHECK (slot_minutes IN (10,15,20,30,60))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7) doctor_schedules : ตารางออกตรวจประจำสัปดาห์
--    หนึ่งแถว = หนึ่งช่วงเวลาในหนึ่งวัน (เช้า/บ่าย แยกแถว)
--    weekday: 0=อาทิตย์ 1=จันทร์ ... 6=เสาร์ (ตรงกับ JS getDay())
-- ---------------------------------------------------------------------
CREATE TABLE doctor_schedules (
  schedule_id     INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  doctor_id       INT UNSIGNED     NOT NULL,
  weekday         TINYINT UNSIGNED NOT NULL,
  start_time      TIME             NOT NULL,
  end_time        TIME             NOT NULL,
  PRIMARY KEY (schedule_id),
  UNIQUE KEY uq_schedule (doctor_id, weekday, start_time),
  CONSTRAINT fk_schedule_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_sched_weekday CHECK (weekday BETWEEN 0 AND 6),
  CONSTRAINT chk_sched_time    CHECK (end_time > start_time)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8) doctor_leaves : วันที่แพทย์งดออกตรวจ (ลา/ติดภารกิจ) — ปิดการจองวันนั้น
-- ---------------------------------------------------------------------
CREATE TABLE doctor_leaves (
  leave_id        INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  doctor_id       INT UNSIGNED  NOT NULL,
  leave_date      DATE          NOT NULL,
  reason          VARCHAR(255)  NULL,
  PRIMARY KEY (leave_id),
  UNIQUE KEY uq_leave (doctor_id, leave_date),
  CONSTRAINT fk_leave_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9) appointments : การจองนัด (หัวใจของระบบ)
--    status flow:
--      pending  -> upcoming (รพ.ยืนยัน) -> seen (ตรวจแล้ว) | noshow
--      pending  -> proposed (รพ.เสนอเวลาใหม่) -> upcoming | cancelled
--      * -> cancelled (cancelled_by = patient/hospital)
-- ---------------------------------------------------------------------
CREATE TABLE appointments (
  appointment_id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  patient_id        INT UNSIGNED  NOT NULL,
  doctor_id         INT UNSIGNED  NOT NULL,
  appt_date         DATE          NOT NULL,
  appt_time         TIME          NOT NULL,
  symptom_note      VARCHAR(500)  NULL,              -- อาการที่แจ้งตอนจอง
  status            ENUM('pending','proposed','upcoming','seen','noshow','cancelled')
                                  NOT NULL DEFAULT 'pending',
  is_follow_up      BOOLEAN       NOT NULL DEFAULT FALSE,
  follow_up_of      INT UNSIGNED  NULL,              -- นัดเดิมที่ทำให้เกิดนัดติดตามนี้
  confirmed_by      INT UNSIGNED  NULL,              -- staff ที่กดยืนยัน
  confirmed_at      DATETIME      NULL,
  cancelled_by      ENUM('patient','hospital') NULL,
  cancel_reason     VARCHAR(255)  NULL,
  cancelled_at      DATETIME      NULL,
  created_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (appointment_id),
  KEY idx_appt_slot    (doctor_id, appt_date, appt_time, status),
  KEY idx_appt_patient (patient_id, appt_date),
  KEY idx_appt_status  (status, created_at),
  KEY idx_appt_followup (follow_up_of),
  KEY idx_appt_confirmed_by (confirmed_by),
  CONSTRAINT fk_appt_patient
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_appt_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_appt_followup
    FOREIGN KEY (follow_up_of) REFERENCES appointments (appointment_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_appt_confirmed_by
    FOREIGN KEY (confirmed_by) REFERENCES staff (staff_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_appt_cancel CHECK (
    (status =  'cancelled' AND cancelled_by IS NOT NULL) OR
    (status <> 'cancelled' AND cancelled_by IS NULL)
  )
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 10) reschedule_proposals : รพ.เสนอวัน/เวลาใหม่ให้คนไข้ตอบรับ/ปฏิเสธ
-- ---------------------------------------------------------------------
CREATE TABLE reschedule_proposals (
  proposal_id       INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  appointment_id    INT UNSIGNED  NOT NULL,
  new_doctor_id     INT UNSIGNED  NOT NULL,     -- อาจเสนอเปลี่ยนแพทย์ด้วย
  new_date          DATE          NOT NULL,
  new_time          TIME          NOT NULL,
  reason            VARCHAR(255)  NULL,
  proposed_by       INT UNSIGNED  NULL,         -- staff
  response          ENUM('waiting','accepted','declined','expired')
                                  NOT NULL DEFAULT 'waiting',
  proposed_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  responded_at      DATETIME      NULL,
  PRIMARY KEY (proposal_id),
  KEY idx_prop_appt (appointment_id, response),
  KEY idx_prop_slot (new_doctor_id, new_date, new_time),
  KEY idx_prop_staff (proposed_by),
  CONSTRAINT fk_prop_appt
    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_prop_doctor
    FOREIGN KEY (new_doctor_id) REFERENCES doctors (doctor_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_prop_staff
    FOREIGN KEY (proposed_by) REFERENCES staff (staff_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 11) medical_reports : ผลตรวจ/คำวินิจฉัยที่เจ้าหน้าที่บันทึกให้คนไข้
--     ผูกกับนัด (หรือ NULL ถ้าเป็นผลที่ไม่ได้มาจากนัดในระบบ)
-- ---------------------------------------------------------------------
CREATE TABLE medical_reports (
  report_id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  patient_id           INT UNSIGNED  NOT NULL,
  hospital_id          INT UNSIGNED  NOT NULL,
  appointment_id       INT UNSIGNED  NULL,
  doctor_id            INT UNSIGNED  NULL,
  visit_date           DATE          NOT NULL,
  diagnosis            VARCHAR(500)  NOT NULL,
  advice               TEXT          NULL,
  next_appointment_id  INT UNSIGNED  NULL,       -- นัดติดตามที่สร้างจากผลนี้
  is_closed            BOOLEAN       NOT NULL DEFAULT TRUE,  -- FALSE = ยังมีนัดติดตาม
  seen_by_patient      BOOLEAN       NOT NULL DEFAULT FALSE,
  created_by           INT UNSIGNED  NULL,       -- staff ผู้บันทึก
  created_at           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (report_id),
  KEY idx_report_patient (patient_id, visit_date),
  KEY idx_report_hospital (hospital_id),
  KEY idx_report_appt (appointment_id),
  KEY idx_report_doctor (doctor_id),
  KEY idx_report_next (next_appointment_id),
  KEY idx_report_creator (created_by),
  CONSTRAINT fk_report_patient
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_report_hospital
    FOREIGN KEY (hospital_id) REFERENCES hospitals (hospital_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_report_appt
    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_report_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_report_next_appt
    FOREIGN KEY (next_appointment_id) REFERENCES appointments (appointment_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_report_creator
    FOREIGN KEY (created_by) REFERENCES staff (staff_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 12) prescriptions : รายการยาในแต่ละผลตรวจ (1 report : N ยา)
-- ---------------------------------------------------------------------
CREATE TABLE prescriptions (
  prescription_id  INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  report_id        INT UNSIGNED      NOT NULL,
  drug_name        VARCHAR(150)      NOT NULL,   -- 'Omeprazole 20 mg'
  dosage           VARCHAR(255)      NOT NULL,   -- '1 เม็ด เช้า ก่อนอาหาร 30 นาที'
  duration_days    SMALLINT UNSIGNED NULL,
  PRIMARY KEY (prescription_id),
  KEY idx_rx_report (report_id),
  CONSTRAINT fk_rx_report
    FOREIGN KEY (report_id) REFERENCES medical_reports (report_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 13) report_files : ไฟล์แนบผลตรวจ (รูป/PDF) — เก็บ path ไม่เก็บ BLOB
-- ---------------------------------------------------------------------
CREATE TABLE report_files (
  file_id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  report_id        INT UNSIGNED  NOT NULL,
  file_name        VARCHAR(255)  NOT NULL,
  mime_type        VARCHAR(100)  NOT NULL,
  file_path        VARCHAR(500)  NOT NULL,
  file_size_bytes  INT UNSIGNED  NULL,
  uploaded_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (file_id),
  KEY idx_file_report (report_id),
  CONSTRAINT fk_file_report
    FOREIGN KEY (report_id) REFERENCES medical_reports (report_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 14) support_tickets : แจ้งปัญหาการใช้งาน (คนไข้ หรือ guest ที่ไม่ได้ login)
-- ---------------------------------------------------------------------
CREATE TABLE support_tickets (
  ticket_id        INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  patient_id       INT UNSIGNED  NULL,            -- NULL = guest
  guest_name       VARCHAR(120)  NULL,
  guest_contact    VARCHAR(120)  NULL,
  topic            VARCHAR(80)   NULL,
  appointment_id   INT UNSIGNED  NULL,
  hospital_id      INT UNSIGNED  NULL,
  message          TEXT          NOT NULL,
  status           ENUM('open','resolved') NOT NULL DEFAULT 'open',
  resolution_note  VARCHAR(500)  NULL,
  resolved_by      INT UNSIGNED  NULL,            -- account (staff/admin)
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at      DATETIME      NULL,
  PRIMARY KEY (ticket_id),
  KEY idx_ticket_status (status, created_at),
  KEY idx_ticket_patient (patient_id),
  KEY idx_ticket_appt (appointment_id),
  KEY idx_ticket_hosp (hospital_id),
  KEY idx_ticket_resolver (resolved_by),
  CONSTRAINT fk_ticket_patient
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_ticket_appt
    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_ticket_hosp
    FOREIGN KEY (hospital_id) REFERENCES hospitals (hospital_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_ticket_resolver
    FOREIGN KEY (resolved_by) REFERENCES accounts (account_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 15) notifications : การแจ้งเตือน ส่งถึง ผู้ใช้รายคน / ทุกเจ้าหน้าที่ของ รพ. / แอดมิน
-- ---------------------------------------------------------------------
CREATE TABLE notifications (
  notification_id      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  target_type          ENUM('account','hospital','admin') NOT NULL,
  target_account_id    INT UNSIGNED  NULL,      -- ใช้เมื่อ target_type='account'
  target_hospital_id   INT UNSIGNED  NULL,      -- ใช้เมื่อ target_type='hospital'
  message              VARCHAR(500)  NOT NULL,
  link_tab             VARCHAR(30)   NULL,      -- หน้าที่จะเปิดเมื่อกด เช่น 'appts','requests'
  appointment_id       INT UNSIGNED  NULL,
  created_at           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (notification_id),
  KEY idx_notif_account (target_account_id, created_at),
  KEY idx_notif_hosp (target_hospital_id, created_at),
  KEY idx_notif_type (target_type, created_at),
  KEY idx_notif_appt (appointment_id),
  CONSTRAINT fk_notif_account
    FOREIGN KEY (target_account_id) REFERENCES accounts (account_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_notif_hosp
    FOREIGN KEY (target_hospital_id) REFERENCES hospitals (hospital_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_notif_appt
    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 16) notification_reads : ใครอ่านแจ้งเตือนไหนแล้ว (M:N accounts <-> notifications)
-- ---------------------------------------------------------------------
CREATE TABLE notification_reads (
  notification_id  INT UNSIGNED  NOT NULL,
  account_id       INT UNSIGNED  NOT NULL,
  read_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (notification_id, account_id),
  KEY idx_read_account (account_id),
  CONSTRAINT fk_read_notif
    FOREIGN KEY (notification_id) REFERENCES notifications (notification_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_read_account
    FOREIGN KEY (account_id) REFERENCES accounts (account_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 17) audit_logs : บันทึกการกระทำสำคัญ (รีเซ็ต/เปลี่ยนรหัสผ่าน, แอดมินเข้าใช้แทนผู้ใช้)
-- ---------------------------------------------------------------------
CREATE TABLE audit_logs (
  log_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  event_type         ENUM('pw_reset_request','pw_reset','pw_changed',
                          'act_start','act_end','account_approved',
                          'account_disabled','other') NOT NULL,
  actor_account_id   INT UNSIGNED    NULL,     -- ผู้กระทำ (เช่น แอดมิน)
  target_account_id  INT UNSIGNED    NULL,     -- บัญชีที่ถูกกระทำ
  ref_log_id         BIGINT UNSIGNED NULL,     -- act_end อ้างถึง act_start
  reason             VARCHAR(100)    NULL,
  note               VARCHAR(500)    NULL,
  duration_sec       INT UNSIGNED    NULL,
  created_at         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (log_id),
  KEY idx_audit_type (event_type, created_at),
  KEY idx_audit_actor (actor_account_id),
  KEY idx_audit_target (target_account_id),
  KEY idx_audit_ref (ref_log_id),
  CONSTRAINT fk_audit_actor
    FOREIGN KEY (actor_account_id) REFERENCES accounts (account_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_audit_target
    FOREIGN KEY (target_account_id) REFERENCES accounts (account_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_audit_ref
    FOREIGN KEY (ref_log_id) REFERENCES audit_logs (log_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =====================================================================
--  TRIGGER: กันจองเกินความจุของช่องเวลา (slot_capacity) และกันจองวันหยุดแพทย์
--  ช่องที่ "ถูกใช้" = นัดที่ยังไม่ถูกยกเลิก (ตรงกับ logic ในแอป)
-- =====================================================================
DELIMITER $$

CREATE TRIGGER trg_appt_before_insert
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
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

DELIMITER ;


-- =====================================================================
--  VIEW: ช่วยสรุปจำนวนนัดที่ยังไม่ยกเลิกต่อช่องเวลา (ใช้แสดงช่องว่างในหน้าเลือกเวลา)
-- =====================================================================
CREATE VIEW v_slot_usage AS
SELECT a.doctor_id,
       a.appt_date,
       a.appt_time,
       COUNT(*)                         AS booked,
       d.slot_capacity                  AS capacity,
       d.slot_capacity - COUNT(*)       AS seats_left
  FROM appointments a
  JOIN doctors d ON d.doctor_id = a.doctor_id
 WHERE a.status <> 'cancelled'
 GROUP BY a.doctor_id, a.appt_date, a.appt_time, d.slot_capacity;
