const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');
const { asyncHandler, httpError } = require('../utils/http');
const { authenticate } = require('../middleware/auth');

router.post('/register', asyncHandler(async (req, res) => {
  const { full_name, email, password, phone, hn, date_of_birth, gender, allergies } = req.body;
  if (!full_name || !email || !password) throw httpError(400, 'กรุณาระบุชื่อ อีเมล และรหัสผ่าน');
  if (String(password).length < 8) throw httpError(400, 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร');
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [result] = await connection.execute(
      `INSERT INTO accounts (role, full_name, email, password_hash, phone, status)
       VALUES ('patient', ?, ?, ?, ?, 'active')`,
      [String(full_name).trim(), String(email).trim().toLowerCase(), await bcrypt.hash(password, 12), phone || null]
    );
    await connection.execute(
      `INSERT INTO patients (patient_id, hn, date_of_birth, gender, allergies) VALUES (?, ?, ?, ?, ?)`,
      [result.insertId, hn || null, date_of_birth || null, gender || null, allergies || null]
    );
    await connection.commit();
    res.status(201).json({ success: true, message: 'สมัครสมาชิกสำเร็จ', account_id: result.insertId });
  } catch (e) { await connection.rollback(); throw e; }
  finally { connection.release(); }
}));

router.post('/login', asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) throw httpError(400, 'กรุณาระบุอีเมลและรหัสผ่าน');
  const [rows] = await db.execute(
    `SELECT account_id, role, full_name, email, password_hash, status, must_change_pw
     FROM accounts WHERE email = ? LIMIT 1`, [String(email).trim().toLowerCase()]
  );
  const account = rows[0];
  if (!account || !(await bcrypt.compare(password, account.password_hash))) throw httpError(401, 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
  if (account.status !== 'active') throw httpError(403, 'บัญชีนี้ยังไม่พร้อมใช้งาน');
  const token = jwt.sign(
    { account_id: account.account_id, role: account.role, full_name: account.full_name },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '8h' }
  );
  res.json({ success: true, token, user: {
    account_id: account.account_id, role: account.role, full_name: account.full_name,
    email: account.email, must_change_pw: Boolean(account.must_change_pw)
  }});
}));

router.get('/me', authenticate, asyncHandler(async (req, res) => {
  const [rows] = await db.execute(
    `SELECT account_id, role, full_name, email, phone, status, must_change_pw, created_at
     FROM accounts WHERE account_id = ?`, [req.user.account_id]
  );
  if (!rows.length) throw httpError(404, 'ไม่พบบัญชี');
  res.json({ success: true, user: rows[0] });
}));

router.patch('/change-password', authenticate, asyncHandler(async (req, res) => {
  const { current_password, new_password } = req.body;
  if (!current_password || !new_password || String(new_password).length < 8) throw httpError(400, 'กรุณาระบุรหัสผ่านเดิมและรหัสผ่านใหม่อย่างน้อย 8 ตัวอักษร');
  const [rows] = await db.execute('SELECT password_hash FROM accounts WHERE account_id = ?', [req.user.account_id]);
  if (!rows.length || !(await bcrypt.compare(current_password, rows[0].password_hash))) throw httpError(400, 'รหัสผ่านเดิมไม่ถูกต้อง');
  await db.execute('UPDATE accounts SET password_hash = ?, must_change_pw = FALSE WHERE account_id = ?', [await bcrypt.hash(new_password, 12), req.user.account_id]);
  await db.execute(`INSERT INTO audit_logs (event_type, actor_account_id, target_account_id) VALUES ('pw_changed', ?, ?)`, [req.user.account_id, req.user.account_id]);
  res.json({ success: true, message: 'เปลี่ยนรหัสผ่านสำเร็จ' });
}));
module.exports = router;
