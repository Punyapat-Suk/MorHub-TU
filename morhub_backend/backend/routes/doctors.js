const router = require('express').Router();
const db = require('../config/database');
const { asyncHandler } = require('../utils/http');
const { authenticate } = require('../middleware/auth');

router.get('/departments', asyncHandler(async (req, res) => {
  const [rows] = await db.execute('SELECT department_id, dept_code, dept_name_th, dept_name_en, icon FROM departments ORDER BY dept_name_th');
  res.json({ success: true, data: rows });
}));
router.get('/', asyncHandler(async (req, res) => {
  const { hospital_id, department_id, q } = req.query;
  let sql = `SELECT d.doctor_id, d.hospital_id, h.hospital_name, d.department_id,
                    dep.dept_name_th, dep.dept_name_en, d.title, d.full_name, d.room,
                    d.experience_years, d.slot_minutes, d.slot_capacity
             FROM doctors d JOIN hospitals h ON h.hospital_id=d.hospital_id
             JOIN departments dep ON dep.department_id=d.department_id WHERE d.is_active=1`;
  const params = [];
  if (hospital_id) { sql += ' AND d.hospital_id=?'; params.push(hospital_id); }
  if (department_id) { sql += ' AND d.department_id=?'; params.push(department_id); }
  if (q) { sql += ' AND (d.full_name LIKE ? OR dep.dept_name_th LIKE ?)'; params.push(`%${q}%`, `%${q}%`); }
  sql += ' ORDER BY dep.dept_name_th, d.full_name';
  const [rows] = await db.execute(sql, params);
  res.json({ success: true, data: rows });
}));
router.get('/:id/schedules', authenticate, asyncHandler(async (req, res) => {
  const [rows] = await db.execute(
    `SELECT schedule_id, weekday, start_time, end_time FROM doctor_schedules WHERE doctor_id=? ORDER BY weekday,start_time`, [req.params.id]
  );
  res.json({ success: true, data: rows });
}));
module.exports = router;
