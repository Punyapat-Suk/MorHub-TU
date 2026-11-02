const router = require('express').Router();
const db = require('../config/database');
const { asyncHandler, httpError } = require('../utils/http');
const { authenticate, allowRoles } = require('../middleware/auth');
const { writeAudit } = require('../services/audit');
router.use(authenticate);

router.get('/', asyncHandler(async (req, res) => {
  let sql = `SELECT a.*, d.full_name AS doctor_name, d.title, dep.dept_name_th,
                    h.hospital_name, p.hn
             FROM appointments a JOIN doctors d ON d.doctor_id=a.doctor_id
             JOIN departments dep ON dep.department_id=d.department_id
             JOIN hospitals h ON h.hospital_id=d.hospital_id
             JOIN patients p ON p.patient_id=a.patient_id`;
  const params = [];
  if (req.user.role === 'patient') { sql += ' WHERE a.patient_id=?'; params.push(req.user.account_id); }
  else if (req.user.role === 'staff') {
    const [staff] = await db.execute('SELECT hospital_id FROM staff WHERE staff_id=?', [req.user.account_id]);
    if (!staff.length) throw httpError(403, 'ไม่พบข้อมูลเจ้าหน้าที่');
    sql += ' WHERE d.hospital_id=?'; params.push(staff[0].hospital_id);
  }
  sql += ' ORDER BY a.appt_date DESC, a.appt_time DESC LIMIT 300';
  const [rows] = await db.execute(sql, params);
  res.json({ success: true, data: rows });
}));

router.post('/', allowRoles('patient'), asyncHandler(async (req, res) => {
  const { doctor_id, appt_date, appt_time, symptom_note, is_follow_up, follow_up_of } = req.body;
  if (!doctor_id || !appt_date || !appt_time) throw httpError(400, 'กรุณาระบุแพทย์ วันที่ และเวลา');
  if (new Date(`${appt_date}T${appt_time}:00`) < new Date()) throw httpError(400, 'ไม่สามารถจองวันเวลาที่ผ่านมาแล้ว');
  const [result] = await db.execute(
    `INSERT INTO appointments (patient_id, doctor_id, appt_date, appt_time, symptom_note, is_follow_up, follow_up_of)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [req.user.account_id, doctor_id, appt_date, appt_time, symptom_note || null, Boolean(is_follow_up), follow_up_of || null]
  );
  res.status(201).json({ success: true, message: 'ส่งคำขอนัดหมายแล้ว', appointment_id: result.insertId, status: 'pending' });
}));

router.patch('/:id/cancel', asyncHandler(async (req, res) => {
  const { reason } = req.body;
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [rows] = await connection.execute('SELECT patient_id,status FROM appointments WHERE appointment_id=? FOR UPDATE', [req.params.id]);
    if (!rows.length) throw httpError(404, 'ไม่พบนัดหมาย');
    const appt = rows[0];
    if (req.user.role === 'patient' && appt.patient_id !== req.user.account_id) throw httpError(403, 'ไม่มีสิทธิ์ยกเลิกนัดนี้');
    if (!['patient','staff','admin'].includes(req.user.role)) throw httpError(403, 'ไม่มีสิทธิ์');
    if (['seen','noshow','cancelled'].includes(appt.status)) throw httpError(400, 'สถานะนัดหมายนี้ไม่สามารถยกเลิกได้');
    const cancelledBy = req.user.role === 'patient' ? 'patient' : 'hospital';
    await connection.execute(
      `UPDATE appointments SET status='cancelled', cancelled_by=?, cancel_reason=?, cancelled_at=NOW() WHERE appointment_id=?`,
      [cancelledBy, reason || null, req.params.id]
    );
    await connection.commit();
    res.json({ success: true, message: 'ยกเลิกนัดหมายแล้ว' });
  } catch (e) { await connection.rollback(); throw e; }
  finally { connection.release(); }
}));

router.patch('/:id/confirm', allowRoles('staff','admin'), asyncHandler(async (req, res) => {
  const [rows] = await db.execute('SELECT status FROM appointments WHERE appointment_id=?', [req.params.id]);
  if (!rows.length) throw httpError(404, 'ไม่พบนัดหมาย');
  if (rows[0].status !== 'pending') throw httpError(400, 'ยืนยันได้เฉพาะนัดที่รอดำเนินการ');
  if (req.user.role === 'staff') {
    const [scope] = await db.execute(`SELECT d.hospital_id FROM appointments a JOIN doctors d ON d.doctor_id=a.doctor_id WHERE a.appointment_id=?`, [req.params.id]);
    const [staff] = await db.execute('SELECT hospital_id FROM staff WHERE staff_id=?', [req.user.account_id]);
    if (!scope.length || !staff.length || scope[0].hospital_id !== staff[0].hospital_id) throw httpError(403, 'ไม่มีสิทธิ์จัดการนัดนี้');
  }
  await db.execute(`UPDATE appointments SET status='upcoming', confirmed_by=?, confirmed_at=NOW() WHERE appointment_id=?`, [req.user.role === 'staff' ? req.user.account_id : null, req.params.id]);
  await db.execute(`INSERT INTO notifications (target_type,target_account_id,message,link_tab,appointment_id)
    SELECT 'account',patient_id,'โรงพยาบาลยืนยันนัดหมายของคุณแล้ว','appts',appointment_id FROM appointments WHERE appointment_id=?`, [req.params.id]);
  res.json({ success: true, message: 'ยืนยันนัดหมายสำเร็จ' });
}));

router.patch('/:id/complete', allowRoles('staff','admin'), asyncHandler(async (req, res) => {
  const [rows] = await db.execute('SELECT status FROM appointments WHERE appointment_id=?', [req.params.id]);
  if (!rows.length) throw httpError(404, 'ไม่พบนัดหมาย');
  if (!['upcoming'].includes(rows[0].status)) throw httpError(400, 'นัดนี้ยังไม่อยู่ในสถานะที่ตรวจเสร็จได้');
  await db.execute(`UPDATE appointments SET status='seen' WHERE appointment_id=?`, [req.params.id]);
  res.json({ success: true, message: 'บันทึกว่าตรวจแล้ว' });
}));
module.exports = router;
