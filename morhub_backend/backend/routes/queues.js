const router = require('express').Router();
const db = require('../config/database');
const { asyncHandler, httpError } = require('../utils/http');
const { authenticate, allowRoles } = require('../middleware/auth');
router.use(authenticate, allowRoles('staff','admin'));

async function assertHospitalAccess(req, hospitalId) {
  if (req.user.role === 'admin') return;
  const [rows] = await db.execute('SELECT hospital_id FROM staff WHERE staff_id=?', [req.user.account_id]);
  if (!rows.length || Number(rows[0].hospital_id) !== Number(hospitalId)) throw httpError(403, 'ไม่มีสิทธิ์เข้าถึงคิวโรงพยาบาลนี้');
}
router.get('/', asyncHandler(async (req, res) => {
  const date = req.query.date || new Date().toLocaleDateString('en-CA', { timeZone: 'Asia/Bangkok' });
  let hospitalId = req.query.hospital_id;
  if (req.user.role === 'staff') {
    const [rows] = await db.execute('SELECT hospital_id FROM staff WHERE staff_id=?', [req.user.account_id]);
    if (!rows.length) throw httpError(403, 'ไม่พบข้อมูลเจ้าหน้าที่');
    hospitalId = rows[0].hospital_id;
  }
  if (!hospitalId) throw httpError(400, 'กรุณาระบุ hospital_id');
  await assertHospitalAccess(req, hospitalId);
  const [rows] = await db.execute(
    `SELECT q.queue_id,q.queue_number,q.queue_date,q.status,q.created_at,q.called_at,q.completed_at,
            a.appointment_id,a.appt_time,p.hn,ac.full_name AS patient_name,
            d.full_name AS doctor_name,dep.dept_name_th
     FROM queues q JOIN appointments a ON a.appointment_id=q.appointment_id
     JOIN patients p ON p.patient_id=q.patient_id JOIN accounts ac ON ac.account_id=q.patient_id
     JOIN doctors d ON d.doctor_id=q.doctor_id JOIN departments dep ON dep.department_id=q.department_id
     WHERE q.hospital_id=? AND q.queue_date=? ORDER BY q.queue_number`, [hospitalId,date]
  );
  res.json({ success: true, data: rows });
}));
router.patch('/:id/call', asyncHandler(async (req, res) => {
  const [rows] = await db.execute('SELECT hospital_id,status FROM queues WHERE queue_id=?', [req.params.id]);
  if (!rows.length) throw httpError(404, 'ไม่พบคิว');
  await assertHospitalAccess(req, rows[0].hospital_id);
  if (rows[0].status !== 'waiting') throw httpError(400, 'เรียกได้เฉพาะคิวที่กำลังรอ');
  await db.execute(`UPDATE queues SET status='called',called_at=NOW() WHERE queue_id=?`, [req.params.id]);
  res.json({ success: true, message: 'เรียกคิวแล้ว' });
}));
router.patch('/:id/complete', asyncHandler(async (req, res) => {
  const [rows] = await db.execute('SELECT hospital_id,status,appointment_id FROM queues WHERE queue_id=?', [req.params.id]);
  if (!rows.length) throw httpError(404, 'ไม่พบคิว');
  await assertHospitalAccess(req, rows[0].hospital_id);
  if (!['called','waiting'].includes(rows[0].status)) throw httpError(400, 'คิวนี้เสร็จสิ้นแล้ว');
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    await connection.execute(`UPDATE queues SET status='completed',completed_at=NOW() WHERE queue_id=?`, [req.params.id]);
    await connection.execute(`UPDATE appointments SET status='seen' WHERE appointment_id=? AND status='upcoming'`, [rows[0].appointment_id]);
    await connection.commit();
    res.json({ success: true, message: 'ปิดคิวและอัปเดตนัดหมายแล้ว' });
  } catch(e) { await connection.rollback(); throw e; }
  finally { connection.release(); }
}));
module.exports = router;
