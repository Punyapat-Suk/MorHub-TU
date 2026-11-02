const router = require('express').Router();
const db = require('../config/database');
const { asyncHandler, httpError } = require('../utils/http');
const { authenticate, allowRoles } = require('../middleware/auth');
router.use(authenticate, allowRoles('staff','admin'));
router.get('/', asyncHandler(async (req, res) => {
  const from = req.query.from || new Date().toLocaleDateString('en-CA', { timeZone: 'Asia/Bangkok' });
  const to = req.query.to || from;
  let hospitalId = req.query.hospital_id || null;
  if (req.user.role === 'staff') {
    const [staff] = await db.execute('SELECT hospital_id FROM staff WHERE staff_id=?', [req.user.account_id]);
    if (!staff.length) throw httpError(403, 'ไม่พบข้อมูลเจ้าหน้าที่');
    hospitalId = staff[0].hospital_id;
  }
  let scope = ''; const params = [from,to];
  if (hospitalId) { scope = ' AND d.hospital_id=?'; params.push(hospitalId); }
  const [summary] = await db.execute(
    `SELECT COUNT(*) AS total_appointments,
       SUM(a.status='pending') AS pending,
       SUM(a.status='upcoming') AS upcoming,
       SUM(a.status='seen') AS seen,
       SUM(a.status='noshow') AS noshow,
       SUM(a.status='cancelled') AS cancelled
     FROM appointments a JOIN doctors d ON d.doctor_id=a.doctor_id
     WHERE a.appt_date BETWEEN ? AND ?${scope}`, params
  );
  const [byDepartment] = await db.execute(
    `SELECT dep.department_id,dep.dept_name_th,COUNT(a.appointment_id) AS total
     FROM departments dep JOIN doctors d ON d.department_id=dep.department_id
     LEFT JOIN appointments a ON a.doctor_id=d.doctor_id AND a.appt_date BETWEEN ? AND ?
       AND a.status <> 'cancelled'
     WHERE 1=1${hospitalId ? ' AND d.hospital_id=?' : ''}
     GROUP BY dep.department_id,dep.dept_name_th ORDER BY total DESC`, params
  );
  res.json({ success: true, period: { from,to }, summary: summary[0], by_department: byDepartment });
}));
module.exports = router;
