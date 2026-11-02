const router = require('express').Router();
const db = require('../config/database');
const { asyncHandler, httpError } = require('../utils/http');
const { authenticate, allowRoles } = require('../middleware/auth');
router.use(authenticate, allowRoles('staff','admin'));

async function verifyDoctorScope(req, doctorId) {
  if (req.user.role === 'admin') return;
  const [rows] = await db.execute(
    `SELECT d.hospital_id FROM doctors d JOIN staff s ON s.hospital_id=d.hospital_id WHERE d.doctor_id=? AND s.staff_id=?`,
    [doctorId,req.user.account_id]
  );
  if (!rows.length) throw httpError(403,'ไม่มีสิทธิ์จัดการตารางแพทย์นี้');
}
router.post('/', asyncHandler(async (req,res) => {
  const { doctor_id,weekday,start_time,end_time } = req.body;
  if (doctor_id == null || weekday == null || !start_time || !end_time) throw httpError(400,'กรุณาระบุ doctor_id, weekday, start_time และ end_time');
  await verifyDoctorScope(req,doctor_id);
  const [result] = await db.execute(
    'INSERT INTO doctor_schedules (doctor_id,weekday,start_time,end_time) VALUES (?,?,?,?)',
    [doctor_id,weekday,start_time,end_time]
  );
  res.status(201).json({success:true,schedule_id:result.insertId});
}));
router.delete('/:id', asyncHandler(async (req,res) => {
  const [rows] = await db.execute('SELECT doctor_id FROM doctor_schedules WHERE schedule_id=?',[req.params.id]);
  if (!rows.length) throw httpError(404,'ไม่พบตารางออกตรวจ');
  await verifyDoctorScope(req,rows[0].doctor_id);
  await db.execute('DELETE FROM doctor_schedules WHERE schedule_id=?',[req.params.id]);
  res.json({success:true,message:'ลบตารางออกตรวจแล้ว'});
}));
router.post('/leaves', asyncHandler(async (req,res) => {
  const {doctor_id,leave_date,reason} = req.body;
  if (!doctor_id || !leave_date) throw httpError(400,'กรุณาระบุแพทย์และวันที่ลา');
  await verifyDoctorScope(req,doctor_id);
  const [result] = await db.execute('INSERT INTO doctor_leaves (doctor_id,leave_date,reason) VALUES (?,?,?)',[doctor_id,leave_date,reason || null]);
  res.status(201).json({success:true,leave_id:result.insertId});
}));
router.delete('/leaves/:id', asyncHandler(async (req,res) => {
  const [rows] = await db.execute('SELECT doctor_id FROM doctor_leaves WHERE leave_id=?',[req.params.id]);
  if (!rows.length) throw httpError(404,'ไม่พบข้อมูลวันลา');
  await verifyDoctorScope(req,rows[0].doctor_id);
  await db.execute('DELETE FROM doctor_leaves WHERE leave_id=?',[req.params.id]);
  res.json({success:true,message:'ลบวันลาแล้ว'});
}));
module.exports = router;
