const router = require('express').Router();
const db = require('../config/database');
const { asyncHandler, httpError } = require('../utils/http');
const { authenticate } = require('../middleware/auth');
router.use(authenticate);
router.get('/', asyncHandler(async (req,res) => {
  const [rows] = await db.execute(
    `SELECT n.notification_id,n.message,n.link_tab,n.appointment_id,n.created_at,
       (nr.account_id IS NOT NULL) AS is_read
     FROM notifications n LEFT JOIN notification_reads nr
       ON nr.notification_id=n.notification_id AND nr.account_id=?
     WHERE (n.target_type='account' AND n.target_account_id=?)
        OR (n.target_type='admin' AND ?='admin')
        OR (n.target_type='hospital' AND EXISTS (
          SELECT 1 FROM staff s WHERE s.staff_id=? AND s.hospital_id=n.target_hospital_id
        ))
     ORDER BY n.created_at DESC LIMIT 100`,
    [req.user.account_id,req.user.account_id,req.user.role,req.user.account_id]
  );
  res.json({ success:true,data:rows });
}));
router.post('/:id/read', asyncHandler(async (req,res) => {
  const [rows] = await db.execute(
    `SELECT notification_id FROM notifications n WHERE notification_id=? AND (
      (target_type='account' AND target_account_id=?) OR
      (target_type='admin' AND ?='admin') OR
      (target_type='hospital' AND EXISTS (SELECT 1 FROM staff s WHERE s.staff_id=? AND s.hospital_id=n.target_hospital_id))
    )`, [req.params.id,req.user.account_id,req.user.role,req.user.account_id]
  );
  if (!rows.length) throw httpError(404,'ไม่พบการแจ้งเตือน');
  await db.execute('INSERT IGNORE INTO notification_reads (notification_id,account_id) VALUES (?,?)',[req.params.id,req.user.account_id]);
  res.json({success:true,message:'ทำเครื่องหมายว่าอ่านแล้ว'});
}));
module.exports = router;
