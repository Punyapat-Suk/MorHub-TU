require('dotenv').config();
const bcrypt = require('bcryptjs');
const db = require('../backend/config/database');

(async () => {
  const [,,fullName,email,password] = process.argv;
  if (!fullName || !email || !password || password.length < 8) {
    console.error('Usage: node scripts/create-admin.js "Admin Name" admin@example.com "StrongPassword"');
    process.exit(1);
  }
  try {
    const hash = await bcrypt.hash(password,12);
    const [result] = await db.execute(
      `INSERT INTO accounts (role,full_name,email,password_hash,status)
       VALUES ('admin',?,?,?,'active')`,[fullName,email.toLowerCase(),hash]
    );
    console.log(`Admin account created. account_id=${result.insertId}`);
  } catch (err) {
    console.error('Could not create admin:',err.message);
    process.exitCode = 1;
  } finally { await db.end(); }
})();
