const db = require('../config/database');
async function writeAudit({ eventType = 'other', actorId = null, targetId = null, reason = null, note = null, connection = db }) {
  await connection.execute(
    `INSERT INTO audit_logs (event_type, actor_account_id, target_account_id, reason, note)
     VALUES (?, ?, ?, ?, ?)`,
    [eventType, actorId, targetId, reason, note]
  );
}
module.exports = { writeAudit };
