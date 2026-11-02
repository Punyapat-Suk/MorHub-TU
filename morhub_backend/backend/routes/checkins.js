const router = require('express').Router();
const crypto = require('crypto');
const QRCode = require('qrcode');
const db = require('../config/database');
const { asyncHandler, httpError } = require('../utils/http');
const { authenticate, allowRoles } = require('../middleware/auth');
router.use(authenticate);

// Patient requests a short-lived, one-use QR token for a confirmed appointment.
router.post('/:appointmentId/qr', allowRoles('patient'), asyncHandler(async (req, res) => {
  const [rows] = await db.execute(
    `SELECT appointment_id, patient_id, appt_date, status FROM appointments WHERE appointment_id=? AND patient_id=?`,
    [req.params.appointmentId, req.user.account_id]
  );
  if (!rows.length) throw httpError(404, 'ไม่พบนัดหมายของคุณ');
  const appt = rows[0];
  if (appt.status !== 'upcoming') throw httpError(400, 'สร้าง QR ได้เฉพาะนัดที่โรงพยาบาลยืนยันแล้ว');
  const expiresAt = new Date(Date.now() + Number(process.env.QR_TOKEN_TTL_MINUTES || 1440) * 60000);
  const token = crypto.randomBytes(32).toString('hex');
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  await db.execute(
    `INSERT INTO check_ins (appointment_id, patient_id, qr_token_hash, expires_at, status)
     VALUES (?, ?, ?, ?, 'issued') ON DUPLICATE KEY UPDATE qr_token_hash=VALUES(qr_token_hash), expires_at=VALUES(expires_at), status='issued', checked_in_at=NULL`,
    [appt.appointment_id, appt.patient_id, tokenHash, expiresAt]
  );
  const dataUrl = await QRCode.toDataURL(token, { errorCorrectionLevel: 'M', margin: 2, width: 280 });
  res.json({ success: true, qr_code_data_url: dataUrl, token, expires_at: expiresAt });
}));

// Staff scans the QR payload and submits the raw token. A transaction prevents reuse.
router.post('/scan', allowRoles('staff','admin'), asyncHandler(async (req, res) => {
  const { token } = req.body;
  if (!token || typeof token !== 'string') throw httpError(400, 'กรุณาส่ง QR token');
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [rows] = await connection.execute(
      `SELECT c.checkin_id,c.appointment_id,c.patient_id,c.expires_at,c.status,
              a.appt_date,a.status AS appointment_status,d.hospital_id,d.department_id,d.doctor_id
       FROM check_ins c JOIN appointments a ON a.appointment_id=c.appointment_id
       JOIN doctors d ON d.doctor_id=a.doctor_id
       WHERE c.qr_token_hash=? FOR UPDATE`, [tokenHash]
    );
    if (!rows.length) throw httpError(404, 'QR Code ไม่ถูกต้อง');
    const item = rows[0];
    if (item.status !== 'issued' || new Date(item.expires_at) < new Date()) throw httpError(400, 'QR Code หมดอายุหรือถูกใช้งานแล้ว');
    if (item.appointment_status !== 'upcoming') throw httpError(400, 'นัดหมายนี้ไม่อยู่ในสถานะยืนยันแล้ว');
    if (String(item.appt_date).slice(0,10) !== new Date().toLocaleDateString('en-CA', { timeZone: 'Asia/Bangkok' })) throw httpError(400, 'QR Code ใช้ได้เฉพาะวันที่นัดหมาย');
    if (req.user.role === 'staff') {
      const [staff] = await connection.execute('SELECT hospital_id FROM staff WHERE staff_id=?', [req.user.account_id]);
      if (!staff.length || staff[0].hospital_id !== item.hospital_id) throw httpError(403, 'ไม่มีสิทธิ์ Check-in โรงพยาบาลนี้');
    }
    await connection.execute(`UPDATE check_ins SET status='used', checked_in_at=NOW() WHERE checkin_id=?`, [item.checkin_id]);
    const [existing] = await connection.execute('SELECT queue_id,queue_number,status FROM queues WHERE appointment_id=?', [item.appointment_id]);
    let queue;
    if (existing.length) queue = existing[0];
    else {
      // Serialize queue-number allocation per hospital/day by locking the hospital row.
      await connection.execute('SELECT hospital_id FROM hospitals WHERE hospital_id=? FOR UPDATE', [item.hospital_id]);
      const [maxRows] = await connection.execute(
        'SELECT COALESCE(MAX(queue_number),0)+1 AS next_number FROM queues WHERE hospital_id=? AND queue_date=CURDATE()',
        [item.hospital_id]
      );
      const [insert] = await connection.execute(
        `INSERT INTO queues (appointment_id,patient_id,hospital_id,department_id,doctor_id,queue_number,queue_date,status)
         VALUES (?,?,?,?,?,?,CURDATE(),'waiting')`,
        [item.appointment_id,item.patient_id,item.hospital_id,item.department_id,item.doctor_id,maxRows[0].next_number]
      );
      const [newQueue] = await connection.execute('SELECT queue_id,queue_number,status FROM queues WHERE queue_id=?', [insert.insertId]);
      queue = newQueue[0];
    }
    await connection.commit();
    res.json({ success: true, message: 'Check-in สำเร็จ', queue });
  } catch (e) { await connection.rollback(); throw e; }
  finally { connection.release(); }
}));
module.exports = router;
